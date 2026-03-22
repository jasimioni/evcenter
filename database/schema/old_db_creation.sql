--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- Name: deduplicate(); Type: FUNCTION; Schema: public; Owner: evcenter
--

CREATE FUNCTION deduplicate() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
-- Deduplicate events ON INSERT if they have the same dedup_id as another one
--
-- When deduplication occurs, the trigger updates severity and last_occurrence
-- of the event and increments the value on 'count' field. Other fields are left
-- unchanged, unless update_fields is presente. It has a space separated list of
-- fields that gets changed as well.
--
-- If the field 'trace_dedup' is SET to true, a record is inserted on trace_dedup
-- table.
--
    DECLARE
        update_sql TEXT;
        field      RECORD;
        serial     BIGINT;
    BEGIN
    EXECUTE 'SELECT serial FROM active_events WHERE dedup_id = ' || quote_literal(new.dedup_id) INTO serial;
	IF serial IS NOT NULL THEN
		update_sql := 'UPDATE active_events SET 
                                 severity = ' || quote_literal(NEW.severity) || ',
                                 last_occurrence = ' || quote_literal(NEW.last_occurrence) || ',
                                 count = count + 1';

        IF NEW.update_fields <> '' THEN
            FOR field IN SELECT regexp_split_to_table(NEW.update_fields, E'\\s+') as name LOOP
                update_sql := update_sql || ', ' || quote_ident(field.name) || ' = ' || '$1.' || quote_ident(field.name);
            END LOOP;
        END IF;
        update_sql := update_sql || ' WHERE dedup_id = ' || quote_literal(NEW.dedup_id);
        EXECUTE update_sql USING NEW;

        IF NEW.trace_dedup = true THEN
                INSERT INTO deduplication_trace ( serial, dedup_id, event_id, type, source, node, object, message, occurrence, severity )
                                         VALUES ( serial, NEW.dedup_id, NEW.event_id, NEW.type, NEW.source, NEW.node, NEW.object, NEW.message, current_timestamp, NEW.severity );
        END IF;

		RETURN NULL;
	ELSE
        NEW.start_severity = NEW.severity;
		RETURN NEW;
	END IF;
    END;
$_$;


ALTER FUNCTION public.deduplicate() OWNER TO evcenter;

--
-- Name: delete_cleared(); Type: FUNCTION; Schema: public; Owner: evcenter
--

CREATE FUNCTION delete_cleared() RETURNS integer
    LANGUAGE plpgsql
    AS $$
-- Delete events with Severity = 0 (Clear) and with last_change older than 1 minute.
-- Should be called periodically for housekeeping
    DECLARE
        rowcount int;
    BEGIN
        DELETE FROM active_events WHERE severity = 0 AND current_timestamp - last_change > INTERVAL '1 minute';
        GET DIAGNOSTICS rowcount = ROW_COUNT;
        RETURN rowcount;
    END;
$$;


ALTER FUNCTION public.delete_cleared() OWNER TO evcenter;

--
-- Name: delete_expired(); Type: FUNCTION; Schema: public; Owner: evcenter
--

CREATE FUNCTION delete_expired() RETURNS integer
    LANGUAGE plpgsql
    AS $$
-- Delete events that have max_life defined and that last_change are older than max_file
-- Should be run periodically for housekeeping
    DECLARE
        rowcount int;
    BEGIN
        DELETE FROM active_events WHERE max_life IS NOT NULL AND max_life > 0 AND current_timestamp - last_change > max_life * INTERVAL '1 second';
        GET DIAGNOSTICS rowcount = ROW_COUNT;
        RETURN rowcount;
    END;
$$;


ALTER FUNCTION public.delete_expired() OWNER TO evcenter;

--
-- Name: fault_resolution(); Type: FUNCTION; Schema: public; Owner: evcenter
--

CREATE FUNCTION fault_resolution() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
-- On the occurrence of an event of type 2 (Resolution) clears (set severity to 0) of all
-- events with the same event_id, with types 1 (failure) and 2 (to clear itself).
    BEGIN
        UPDATE active_events SET severity = 0 WHERE event_id = NEW.event_id AND type IN (1, 2) AND severity >= 1;
        RETURN NEW;
    END;
$$;


ALTER FUNCTION public.fault_resolution() OWNER TO evcenter;

--
-- Name: save_deletion_time(); Type: FUNCTION; Schema: public; Owner: evcenter
--

CREATE FUNCTION save_deletion_time() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
-- On DELETION of an event, saves the deletion time to the corresponding event on 
-- history table (history_events)
    BEGIN
        UPDATE history_events SET delete_time = current_timestamp WHERE serial = OLD.serial;
        RETURN OLD;
    END;
$$;


ALTER FUNCTION public.save_deletion_time() OWNER TO evcenter;

--
-- Name: update_last_change(); Type: FUNCTION; Schema: public; Owner: evcenter
--

CREATE FUNCTION update_last_change() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
-- Update the 'last_change' field of an event everytime it gets updated
    BEGIN
        NEW.start_severity := OLD.start_severity;
        NEW.last_change    := current_timestamp;
        RETURN NEW;
    END;
$$;


ALTER FUNCTION public.update_last_change() OWNER TO evcenter;

--
-- Name: z_save_history(); Type: FUNCTION; Schema: public; Owner: evcenter
--

CREATE FUNCTION z_save_history() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
-- INSERT a history row on history_events everytime an event is inserted in active_events
    BEGIN
        INSERT INTO history_events (
            serial,
            dedup_id,
            event_id,
            type,
            event_group,
            source,
            source_type,
            node,
            object,
            message,
            first_occurrence,
            last_occurrence,
            last_change,
            severity,
            count,
            start_severity,
            detail,
            ticket,
            ack,
            owner_uid,
            group_uid,
            suppression,
            correlation_flag,
            max_life,
            clear_time,
            trace_dedup,
            parent,
            has_childs
        ) VALUES (
            NEW.serial,
            NEW.dedup_id,
            NEW.event_id,
            NEW.type,
            NEW.event_group,
            NEW.source,
            NEW.source_type,
            NEW.node,
            NEW.object,
            NEW.message,
            NEW.first_occurrence,
            NEW.last_occurrence,
            NEW.last_change,
            NEW.severity,
            NEW.count,
            NEW.start_severity,
            NEW.detail,
            NEW.ticket,
            NEW.ack,
            NEW.owner_uid,
            NEW.group_uid,
            NEW.suppression,
            NEW.correlation_flag,
            NEW.max_life,
            NEW.clear_time,
            NEW.trace_dedup,
            NEW.parent,
            NEW.has_childs
        );
        RETURN NEW;
    END;
$$;


ALTER FUNCTION public.z_save_history() OWNER TO evcenter;

--
-- Name: z_update_history(); Type: FUNCTION; Schema: public; Owner: evcenter
--

CREATE FUNCTION z_update_history() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
-- Updates the row on history_events everytime an event is updated on active_events
    BEGIN
        UPDATE history_events SET
            serial = NEW.serial,
            dedup_id = NEW.dedup_id,
            event_id = NEW.event_id,
            type = NEW.type,
            event_group = NEW.event_group,
            source = NEW.source,
            source_type = NEW.source_type,
            node = NEW.node,
            object = NEW.object,
            message = NEW.message,
            first_occurrence = NEW.first_occurrence,
            last_occurrence = NEW.last_occurrence,
            last_change = NEW.last_change,
            severity = NEW.severity,
            count = NEW.count,
            start_severity = NEW.start_severity,
            detail = NEW.detail,
            ticket = NEW.ticket,
            ack = NEW.ack,
            owner_uid = NEW.owner_uid,
            group_uid = NEW.group_uid,
            suppression = NEW.suppression,
            correlation_flag = NEW.correlation_flag,
            max_life = NEW.max_life,
            clear_time = NEW.clear_time,
            trace_dedup = NEW.trace_dedup,
            parent = NEW.parent,
            has_childs = NEW.has_childs
        WHERE serial = NEW.serial;
        RETURN NEW;

    END;
$$;


ALTER FUNCTION public.z_update_history() OWNER TO evcenter;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: active_events; Type: TABLE; Schema: public; Owner: evcenter; Tablespace: 
--

CREATE TABLE active_events (
    serial bigint NOT NULL,
    dedup_id text NOT NULL,
    event_id text NOT NULL,
    type integer NOT NULL,
    event_group text,
    source text,
    source_type text,
    node text,
    object text,
    message text,
    first_occurrence timestamp without time zone DEFAULT now(),
    last_occurrence timestamp without time zone DEFAULT now(),
    last_change timestamp without time zone DEFAULT now(),
    severity integer NOT NULL,
    count integer DEFAULT 1,
    start_severity integer,
    detail json,
    ticket text,
    ack smallint,
    owner_uid text,
    group_uid text,
    suppression integer,
    correlation_flag integer,
    max_life integer,
    clear_time timestamp without time zone,
    trace_dedup boolean,
    parent bigint,
    has_childs boolean,
    update_fields text
);


ALTER TABLE public.active_events OWNER TO evcenter;

--
-- Name: active_events_serial_seq; Type: SEQUENCE; Schema: public; Owner: evcenter
--

CREATE SEQUENCE active_events_serial_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.active_events_serial_seq OWNER TO evcenter;

--
-- Name: active_events_serial_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: evcenter
--

ALTER SEQUENCE active_events_serial_seq OWNED BY active_events.serial;


--
-- Name: deduplication_trace; Type: TABLE; Schema: public; Owner: evcenter; Tablespace: 
--

CREATE TABLE deduplication_trace (
    serial bigint NOT NULL,
    dedup_id text NOT NULL,
    event_id text NOT NULL,
    type integer NOT NULL,
    source text,
    node text,
    object text,
    message text,
    occurrence timestamp without time zone,
    severity integer,
    extra_details json
);


ALTER TABLE public.deduplication_trace OWNER TO evcenter;

--
-- Name: history_events; Type: TABLE; Schema: public; Owner: evcenter; Tablespace: 
--

CREATE TABLE history_events (
    serial bigint NOT NULL,
    dedup_id text NOT NULL,
    event_id text NOT NULL,
    type integer NOT NULL,
    event_group text,
    source text,
    source_type text,
    node text,
    object text,
    message text,
    first_occurrence timestamp without time zone DEFAULT now(),
    last_occurrence timestamp without time zone DEFAULT now(),
    last_change timestamp without time zone DEFAULT now(),
    severity integer NOT NULL,
    count integer,
    start_severity integer,
    detail json,
    ticket text,
    ack smallint,
    owner_uid text,
    group_uid text,
    suppression integer,
    correlation_flag integer,
    max_life integer,
    clear_time timestamp without time zone,
    trace_dedup boolean,
    parent bigint,
    has_childs boolean,
    delete_time timestamp without time zone
);


ALTER TABLE public.history_events OWNER TO evcenter;

--
-- Name: log; Type: TABLE; Schema: public; Owner: evcenter; Tablespace: 
--

CREATE TABLE log (
    log_serial bigint NOT NULL,
    event_serial bigint NOT NULL,
    evend_dedup_id text NOT NULL,
    owner_uid text,
    occurrence timestamp without time zone DEFAULT now() NOT NULL,
    log_message text
);


ALTER TABLE public.log OWNER TO evcenter;

--
-- Name: log_log_serial_seq; Type: SEQUENCE; Schema: public; Owner: evcenter
--

CREATE SEQUENCE log_log_serial_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.log_log_serial_seq OWNER TO evcenter;

--
-- Name: log_log_serial_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: evcenter
--

ALTER SEQUENCE log_log_serial_seq OWNED BY log.log_serial;


--
-- Name: serial; Type: DEFAULT; Schema: public; Owner: evcenter
--

ALTER TABLE ONLY active_events ALTER COLUMN serial SET DEFAULT nextval('active_events_serial_seq'::regclass);


--
-- Name: log_serial; Type: DEFAULT; Schema: public; Owner: evcenter
--

ALTER TABLE ONLY log ALTER COLUMN log_serial SET DEFAULT nextval('log_log_serial_seq'::regclass);


--
-- Name: deduplicate; Type: TRIGGER; Schema: public; Owner: evcenter
--

CREATE TRIGGER deduplicate BEFORE INSERT ON active_events FOR EACH ROW EXECUTE PROCEDURE deduplicate();


--
-- Name: fault_resolution; Type: TRIGGER; Schema: public; Owner: evcenter
--

CREATE TRIGGER fault_resolution AFTER INSERT OR UPDATE ON active_events FOR EACH ROW WHEN (((new.type = 2) AND (new.severity >= 1))) EXECUTE PROCEDURE fault_resolution();


--
-- Name: save_deletion_time; Type: TRIGGER; Schema: public; Owner: evcenter
--

CREATE TRIGGER save_deletion_time AFTER DELETE ON active_events FOR EACH ROW EXECUTE PROCEDURE save_deletion_time();


--
-- Name: update_last_change; Type: TRIGGER; Schema: public; Owner: evcenter
--

CREATE TRIGGER update_last_change BEFORE UPDATE ON active_events FOR EACH ROW EXECUTE PROCEDURE update_last_change();


--
-- Name: z_save_history; Type: TRIGGER; Schema: public; Owner: evcenter
--

CREATE TRIGGER z_save_history AFTER INSERT ON active_events FOR EACH ROW EXECUTE PROCEDURE z_save_history();


--
-- Name: z_update_history; Type: TRIGGER; Schema: public; Owner: evcenter
--

CREATE TRIGGER z_update_history AFTER UPDATE ON active_events FOR EACH ROW EXECUTE PROCEDURE z_update_history();


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

