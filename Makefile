# This Makefile is for the EVCenter extension to perl.
#
# It was generated automatically by MakeMaker version
# 7.04 (Revision: 70400) from the contents of
# Makefile.PL. Don't edit this file, edit Makefile.PL instead.
#
#       ANY CHANGES MADE HERE WILL BE LOST!
#
#   MakeMaker ARGV: ()
#

#   MakeMaker Parameters:

#     ABSTRACT => q[Catalyst based application]
#     AUTHOR => [q[JoÃ£o AndrÃ© Simioni]]
#     BUILD_REQUIRES => { ExtUtils::MakeMaker=>q[6.36], Test::More=>q[0.88] }
#     CONFIGURE_REQUIRES => {  }
#     DISTNAME => q[EVCenter]
#     EXE_FILES => [q[script/evcenter_cgi.pl], q[script/evcenter_create.pl], q[script/evcenter_fastcgi.pl], q[script/evcenter_server.pl], q[script/evcenter_test.pl]]
#     LICENSE => q[perl]
#     NAME => q[EVCenter]
#     NO_META => q[1]
#     PREREQ_PM => { Catalyst::Action::RenderView=>q[0], Catalyst::Authentication::Store::DBIx::Class=>q[0], Catalyst::Model::Adaptor=>q[0], Catalyst::Plugin::Compress=>q[0], Catalyst::Plugin::ConfigLoader=>q[0], Catalyst::Plugin::Server::JSONRPC=>q[0], Catalyst::Plugin::Session::State::Stash=>q[0], Catalyst::Plugin::Session::Store::File=>q[0], Catalyst::Plugin::SmartURI=>q[0], Catalyst::Plugin::Static::Simple=>q[0], Catalyst::Plugin::Unicode=>q[0], Catalyst::Runtime=>q[5.90042], Catalyst::View::JSON=>q[0], Catalyst::View::TT=>q[0], Config::General=>q[0], DBD::Pg=>q[0], DBIx::Connector=>q[0], ExtUtils::MakeMaker=>q[6.36], Hash::Merge::Simple=>q[0], JSON::MaybeXS=>q[0], Log::Any::Adapter::Catalyst=>q[0], Module::Pluggable::Object=>q[0], Moose=>q[0], Net::SNMP=>q[0], SQL::Abstract::More=>q[0], Test::More=>q[0.88], common::sense=>q[0], namespace::autoclean=>q[0] }
#     TEST_REQUIRES => {  }
#     VERSION => q[0.02]
#     VERSION_FROM => q[lib/EVCenter.pm]
#     dist => { PREOP=>q[$(PERL) -I. "-MModule::Install::Admin" -e "dist_preop(q($(DISTVNAME)))"] }
#     realclean => { FILES=>q[MYMETA.yml] }
#     test => { TESTS=>q[t/controller_GUI-Admin.t t/controller_GUI-Auth.t t/controller_GUI-Authenticate.t t/controller_GUI.t t/controller_Private-system.t t/controller_Private-usercontrol.t t/model_AuthDB.t t/model_Processor.t t/model_UserControl.t t/view_HTMLBasic.t t/view_HTMLNW.t] }

# --- MakeMaker post_initialize section:


# --- MakeMaker const_config section:

# These definitions are from config.sh (via /usr/lib64/perl5/Config.pm).
# They may have been overridden via Makefile.PL or on the command line.
AR = ar
CC = gcc
CCCDLFLAGS = -fPIC
CCDLFLAGS = -Wl,-E -Wl,-rpath,/usr/lib64/perl5/CORE
DLEXT = so
DLSRC = dl_dlopen.xs
EXE_EXT = 
FULL_AR = /usr/bin/ar
LD = gcc
LDDLFLAGS = -shared -O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=4 -m64 -mtune=generic
LDFLAGS =  -fstack-protector
LIBC = 
LIB_EXT = .a
OBJ_EXT = .o
OSNAME = linux
OSVERS = 2.6.32-220.el6.x86_64
RANLIB = :
SITELIBEXP = /usr/local/share/perl5
SITEARCHEXP = /usr/local/lib64/perl5
SO = so
VENDORARCHEXP = /usr/lib64/perl5/vendor_perl
VENDORLIBEXP = /usr/share/perl5/vendor_perl


# --- MakeMaker constants section:
AR_STATIC_ARGS = cr
DIRFILESEP = /
DFSEP = $(DIRFILESEP)
NAME = EVCenter
NAME_SYM = EVCenter
VERSION = 0.02
VERSION_MACRO = VERSION
VERSION_SYM = 0_02
DEFINE_VERSION = -D$(VERSION_MACRO)=\"$(VERSION)\"
XS_VERSION = 0.02
XS_VERSION_MACRO = XS_VERSION
XS_DEFINE_VERSION = -D$(XS_VERSION_MACRO)=\"$(XS_VERSION)\"
INST_ARCHLIB = blib/arch
INST_SCRIPT = blib/script
INST_BIN = blib/bin
INST_LIB = blib/lib
INST_MAN1DIR = blib/man1
INST_MAN3DIR = blib/man3
MAN1EXT = 1
MAN3EXT = 3pm
INSTALLDIRS = site
DESTDIR = 
PREFIX = $(SITEPREFIX)
PERLPREFIX = /usr
SITEPREFIX = /usr/local
VENDORPREFIX = /usr
INSTALLPRIVLIB = /usr/share/perl5
DESTINSTALLPRIVLIB = $(DESTDIR)$(INSTALLPRIVLIB)
INSTALLSITELIB = /usr/local/share/perl5
DESTINSTALLSITELIB = $(DESTDIR)$(INSTALLSITELIB)
INSTALLVENDORLIB = /usr/share/perl5/vendor_perl
DESTINSTALLVENDORLIB = $(DESTDIR)$(INSTALLVENDORLIB)
INSTALLARCHLIB = /usr/lib64/perl5
DESTINSTALLARCHLIB = $(DESTDIR)$(INSTALLARCHLIB)
INSTALLSITEARCH = /usr/local/lib64/perl5
DESTINSTALLSITEARCH = $(DESTDIR)$(INSTALLSITEARCH)
INSTALLVENDORARCH = /usr/lib64/perl5/vendor_perl
DESTINSTALLVENDORARCH = $(DESTDIR)$(INSTALLVENDORARCH)
INSTALLBIN = /usr/bin
DESTINSTALLBIN = $(DESTDIR)$(INSTALLBIN)
INSTALLSITEBIN = /usr/local/bin
DESTINSTALLSITEBIN = $(DESTDIR)$(INSTALLSITEBIN)
INSTALLVENDORBIN = /usr/bin
DESTINSTALLVENDORBIN = $(DESTDIR)$(INSTALLVENDORBIN)
INSTALLSCRIPT = /usr/bin
DESTINSTALLSCRIPT = $(DESTDIR)$(INSTALLSCRIPT)
INSTALLSITESCRIPT = /usr/local/bin
DESTINSTALLSITESCRIPT = $(DESTDIR)$(INSTALLSITESCRIPT)
INSTALLVENDORSCRIPT = /usr/bin
DESTINSTALLVENDORSCRIPT = $(DESTDIR)$(INSTALLVENDORSCRIPT)
INSTALLMAN1DIR = /usr/share/man/man1
DESTINSTALLMAN1DIR = $(DESTDIR)$(INSTALLMAN1DIR)
INSTALLSITEMAN1DIR = /usr/local/share/man/man1
DESTINSTALLSITEMAN1DIR = $(DESTDIR)$(INSTALLSITEMAN1DIR)
INSTALLVENDORMAN1DIR = /usr/share/man/man1
DESTINSTALLVENDORMAN1DIR = $(DESTDIR)$(INSTALLVENDORMAN1DIR)
INSTALLMAN3DIR = /usr/share/man/man3
DESTINSTALLMAN3DIR = $(DESTDIR)$(INSTALLMAN3DIR)
INSTALLSITEMAN3DIR = /usr/local/share/man/man3
DESTINSTALLSITEMAN3DIR = $(DESTDIR)$(INSTALLSITEMAN3DIR)
INSTALLVENDORMAN3DIR = /usr/share/man/man3
DESTINSTALLVENDORMAN3DIR = $(DESTDIR)$(INSTALLVENDORMAN3DIR)
PERL_LIB =
PERL_ARCHLIB = /usr/lib64/perl5
PERL_ARCHLIBDEP = /usr/lib64/perl5
LIBPERL_A = libperl.a
FIRST_MAKEFILE = Makefile
MAKEFILE_OLD = Makefile.old
MAKE_APERL_FILE = Makefile.aperl
PERLMAINCC = $(CC)
PERL_INC = /usr/lib64/perl5/CORE
PERL_INCDEP = /usr/lib64/perl5/CORE
PERL = "/usr/bin/perl" "-Iinc"
FULLPERL = "/usr/bin/perl" "-Iinc"
ABSPERL = $(PERL)
PERLRUN = $(PERL)
FULLPERLRUN = $(FULLPERL)
ABSPERLRUN = $(ABSPERL)
PERLRUNINST = $(PERLRUN) "-I$(INST_ARCHLIB)" "-Iinc" "-I$(INST_LIB)"
FULLPERLRUNINST = $(FULLPERLRUN) "-I$(INST_ARCHLIB)" "-Iinc" "-I$(INST_LIB)"
ABSPERLRUNINST = $(ABSPERLRUN) "-I$(INST_ARCHLIB)" "-Iinc" "-I$(INST_LIB)"
PERL_CORE = 0
PERM_DIR = 755
PERM_RW = 644
PERM_RWX = 755

MAKEMAKER   = /usr/local/share/perl5/ExtUtils/MakeMaker.pm
MM_VERSION  = 7.04
MM_REVISION = 70400

# FULLEXT = Pathname for extension directory (eg Foo/Bar/Oracle).
# BASEEXT = Basename part of FULLEXT. May be just equal FULLEXT. (eg Oracle)
# PARENT_NAME = NAME without BASEEXT and no trailing :: (eg Foo::Bar)
# DLBASE  = Basename part of dynamic library. May be just equal BASEEXT.
MAKE = make
FULLEXT = EVCenter
BASEEXT = EVCenter
PARENT_NAME = 
DLBASE = $(BASEEXT)
VERSION_FROM = lib/EVCenter.pm
OBJECT = 
LDFROM = $(OBJECT)
LINKTYPE = dynamic
BOOTDEP = 

# Handy lists of source code files:
XS_FILES = 
C_FILES  = 
O_FILES  = 
H_FILES  = 
MAN1PODS = script/evcenter_cgi.pl \
	script/evcenter_create.pl \
	script/evcenter_fastcgi.pl \
	script/evcenter_server.pl \
	script/evcenter_test.pl
MAN3PODS = lib/Auth/Schema/Result/UcUser.pm \
	lib/EVCenter.pm \
	lib/EVCenter/Base/ACL.pm \
	lib/EVCenter/Base/Event.pm \
	lib/EVCenter/Controller/Auth.pm \
	lib/EVCenter/Controller/GUI.pm \
	lib/EVCenter/Controller/GUI/Admin.pm \
	lib/EVCenter/Controller/GUI/EventList.pm \
	lib/EVCenter/Controller/Private/event.pm \
	lib/EVCenter/Controller/Private/system.pm \
	lib/EVCenter/Controller/Private/usercontrol.pm \
	lib/EVCenter/Controller/Root.pm \
	lib/EVCenter/Controller/WebServices.pm \
	lib/EVCenter/Includes/Common/Base.pm \
	lib/EVCenter/Includes/Common/Base_OnLoad.pm \
	lib/EVCenter/Includes/SNMPd/Base_OnLoad.pm \
	lib/EVCenter/Model/AuthDB.pm \
	lib/EVCenter/View/HTML.pm \
	lib/EVCenter/View/HTMLBasic.pm \
	lib/EVCenter/View/HTMLNW.pm \
	lib/EVCenter/View/JSON.pm

# Where is the Config information that we are using/depend on
CONFIGDEP = $(PERL_ARCHLIBDEP)$(DFSEP)Config.pm $(PERL_INCDEP)$(DFSEP)config.h

# Where to build things
INST_LIBDIR      = $(INST_LIB)
INST_ARCHLIBDIR  = $(INST_ARCHLIB)

INST_AUTODIR     = $(INST_LIB)/auto/$(FULLEXT)
INST_ARCHAUTODIR = $(INST_ARCHLIB)/auto/$(FULLEXT)

INST_STATIC      = 
INST_DYNAMIC     = 
INST_BOOT        = 

# Extra linker info
EXPORT_LIST        = 
PERL_ARCHIVE       = 
PERL_ARCHIVEDEP    = 
PERL_ARCHIVE_AFTER = 


TO_INST_PM = lib/Auth/Schema.pm \
	lib/Auth/Schema/Result/UcUser.pm \
	lib/EVCenter.pm \
	lib/EVCenter/Base/ACL.pm \
	lib/EVCenter/Base/Event.pm \
	lib/EVCenter/Base/Event/Processor.pm \
	lib/EVCenter/Base/Event/Processor/Common.pm \
	lib/EVCenter/Base/Event/Processor/Default.pm \
	lib/EVCenter/Base/Event/Processor/SNMPd.pm \
	lib/EVCenter/Base/UserControl.pm \
	lib/EVCenter/Controller/Auth.pm \
	lib/EVCenter/Controller/GUI.pm \
	lib/EVCenter/Controller/GUI/Admin.pm \
	lib/EVCenter/Controller/GUI/EventList.pm \
	lib/EVCenter/Controller/Private/event.pm \
	lib/EVCenter/Controller/Private/system.pm \
	lib/EVCenter/Controller/Private/usercontrol.pm \
	lib/EVCenter/Controller/Root.pm \
	lib/EVCenter/Controller/WebServices.pm \
	lib/EVCenter/Includes/Common/Base.pm \
	lib/EVCenter/Includes/Common/Base_OnLoad.pm \
	lib/EVCenter/Includes/SNMPd/Base.pm \
	lib/EVCenter/Includes/SNMPd/Base_OnLoad.pm \
	lib/EVCenter/Model/ACL.pm \
	lib/EVCenter/Model/AuthDB.pm \
	lib/EVCenter/Model/Event.pm \
	lib/EVCenter/Model/Processor.pm \
	lib/EVCenter/Model/UserControl.pm \
	lib/EVCenter/View/HTML.pm \
	lib/EVCenter/View/HTMLBasic.pm \
	lib/EVCenter/View/HTMLNW.pm \
	lib/EVCenter/View/JSON.pm

PM_TO_BLIB = lib/Auth/Schema.pm \
	blib/lib/Auth/Schema.pm \
	lib/Auth/Schema/Result/UcUser.pm \
	blib/lib/Auth/Schema/Result/UcUser.pm \
	lib/EVCenter.pm \
	blib/lib/EVCenter.pm \
	lib/EVCenter/Base/ACL.pm \
	blib/lib/EVCenter/Base/ACL.pm \
	lib/EVCenter/Base/Event.pm \
	blib/lib/EVCenter/Base/Event.pm \
	lib/EVCenter/Base/Event/Processor.pm \
	blib/lib/EVCenter/Base/Event/Processor.pm \
	lib/EVCenter/Base/Event/Processor/Common.pm \
	blib/lib/EVCenter/Base/Event/Processor/Common.pm \
	lib/EVCenter/Base/Event/Processor/Default.pm \
	blib/lib/EVCenter/Base/Event/Processor/Default.pm \
	lib/EVCenter/Base/Event/Processor/SNMPd.pm \
	blib/lib/EVCenter/Base/Event/Processor/SNMPd.pm \
	lib/EVCenter/Base/UserControl.pm \
	blib/lib/EVCenter/Base/UserControl.pm \
	lib/EVCenter/Controller/Auth.pm \
	blib/lib/EVCenter/Controller/Auth.pm \
	lib/EVCenter/Controller/GUI.pm \
	blib/lib/EVCenter/Controller/GUI.pm \
	lib/EVCenter/Controller/GUI/Admin.pm \
	blib/lib/EVCenter/Controller/GUI/Admin.pm \
	lib/EVCenter/Controller/GUI/EventList.pm \
	blib/lib/EVCenter/Controller/GUI/EventList.pm \
	lib/EVCenter/Controller/Private/event.pm \
	blib/lib/EVCenter/Controller/Private/event.pm \
	lib/EVCenter/Controller/Private/system.pm \
	blib/lib/EVCenter/Controller/Private/system.pm \
	lib/EVCenter/Controller/Private/usercontrol.pm \
	blib/lib/EVCenter/Controller/Private/usercontrol.pm \
	lib/EVCenter/Controller/Root.pm \
	blib/lib/EVCenter/Controller/Root.pm \
	lib/EVCenter/Controller/WebServices.pm \
	blib/lib/EVCenter/Controller/WebServices.pm \
	lib/EVCenter/Includes/Common/Base.pm \
	blib/lib/EVCenter/Includes/Common/Base.pm \
	lib/EVCenter/Includes/Common/Base_OnLoad.pm \
	blib/lib/EVCenter/Includes/Common/Base_OnLoad.pm \
	lib/EVCenter/Includes/SNMPd/Base.pm \
	blib/lib/EVCenter/Includes/SNMPd/Base.pm \
	lib/EVCenter/Includes/SNMPd/Base_OnLoad.pm \
	blib/lib/EVCenter/Includes/SNMPd/Base_OnLoad.pm \
	lib/EVCenter/Model/ACL.pm \
	blib/lib/EVCenter/Model/ACL.pm \
	lib/EVCenter/Model/AuthDB.pm \
	blib/lib/EVCenter/Model/AuthDB.pm \
	lib/EVCenter/Model/Event.pm \
	blib/lib/EVCenter/Model/Event.pm \
	lib/EVCenter/Model/Processor.pm \
	blib/lib/EVCenter/Model/Processor.pm \
	lib/EVCenter/Model/UserControl.pm \
	blib/lib/EVCenter/Model/UserControl.pm \
	lib/EVCenter/View/HTML.pm \
	blib/lib/EVCenter/View/HTML.pm \
	lib/EVCenter/View/HTMLBasic.pm \
	blib/lib/EVCenter/View/HTMLBasic.pm \
	lib/EVCenter/View/HTMLNW.pm \
	blib/lib/EVCenter/View/HTMLNW.pm \
	lib/EVCenter/View/JSON.pm \
	blib/lib/EVCenter/View/JSON.pm


# --- MakeMaker platform_constants section:
MM_Unix_VERSION = 7.04
PERL_MALLOC_DEF = -DPERL_EXTMALLOC_DEF -Dmalloc=Perl_malloc -Dfree=Perl_mfree -Drealloc=Perl_realloc -Dcalloc=Perl_calloc


# --- MakeMaker tool_autosplit section:
# Usage: $(AUTOSPLITFILE) FileToSplit AutoDirToSplitInto
AUTOSPLITFILE = $(ABSPERLRUN)  -e 'use AutoSplit;  autosplit($$$$ARGV[0], $$$$ARGV[1], 0, 1, 1)' --



# --- MakeMaker tool_xsubpp section:


# --- MakeMaker tools_other section:
SHELL = /bin/sh
CHMOD = chmod
CP = cp
MV = mv
NOOP = $(TRUE)
NOECHO = @
RM_F = rm -f
RM_RF = rm -rf
TEST_F = test -f
TOUCH = touch
UMASK_NULL = umask 0
DEV_NULL = > /dev/null 2>&1
MKPATH = $(ABSPERLRUN) -MExtUtils::Command -e 'mkpath' --
EQUALIZE_TIMESTAMP = $(ABSPERLRUN) -MExtUtils::Command -e 'eqtime' --
FALSE = false
TRUE = true
ECHO = echo
ECHO_N = echo -n
UNINST = 0
VERBINST = 0
MOD_INSTALL = $(ABSPERLRUN) -MExtUtils::Install -e 'install([ from_to => {@ARGV}, verbose => '\''$(VERBINST)'\'', uninstall_shadows => '\''$(UNINST)'\'', dir_mode => '\''$(PERM_DIR)'\'' ]);' --
DOC_INSTALL = $(ABSPERLRUN) -MExtUtils::Command::MM -e 'perllocal_install' --
UNINSTALL = $(ABSPERLRUN) -MExtUtils::Command::MM -e 'uninstall' --
WARN_IF_OLD_PACKLIST = $(ABSPERLRUN) -MExtUtils::Command::MM -e 'warn_if_old_packlist' --
MACROSTART = 
MACROEND = 
USEMAKEFILE = -f
FIXIN = $(ABSPERLRUN) -MExtUtils::MY -e 'MY->fixin(shift)' --
CP_NONEMPTY = $(ABSPERLRUN) -MExtUtils::Command::MM -e 'cp_nonempty' --


# --- MakeMaker makemakerdflt section:
makemakerdflt : all
	$(NOECHO) $(NOOP)


# --- MakeMaker dist section:
TAR = tar
TARFLAGS = cvf
ZIP = zip
ZIPFLAGS = -r
COMPRESS = gzip --best
SUFFIX = .gz
SHAR = shar
PREOP = $(PERL) -I. "-MModule::Install::Admin" -e "dist_preop(q($(DISTVNAME)))"
POSTOP = $(NOECHO) $(NOOP)
TO_UNIX = $(NOECHO) $(NOOP)
CI = ci -u
RCS_LABEL = rcs -Nv$(VERSION_SYM): -q
DIST_CP = best
DIST_DEFAULT = tardist
DISTNAME = EVCenter
DISTVNAME = EVCenter-0.02


# --- MakeMaker macro section:


# --- MakeMaker depend section:


# --- MakeMaker cflags section:


# --- MakeMaker const_loadlibs section:


# --- MakeMaker const_cccmd section:


# --- MakeMaker post_constants section:


# --- MakeMaker pasthru section:

PASTHRU = LIBPERL_A="$(LIBPERL_A)"\
	LINKTYPE="$(LINKTYPE)"\
	PREFIX="$(PREFIX)"


# --- MakeMaker special_targets section:
.SUFFIXES : .xs .c .C .cpp .i .s .cxx .cc $(OBJ_EXT)

.PHONY: all config static dynamic test linkext manifest blibdirs clean realclean disttest distdir



# --- MakeMaker c_o section:


# --- MakeMaker xs_c section:


# --- MakeMaker xs_o section:


# --- MakeMaker top_targets section:
all :: pure_all manifypods
	$(NOECHO) $(NOOP)


pure_all :: config pm_to_blib subdirs linkext
	$(NOECHO) $(NOOP)

subdirs :: $(MYEXTLIB)
	$(NOECHO) $(NOOP)

config :: $(FIRST_MAKEFILE) blibdirs
	$(NOECHO) $(NOOP)

help :
	perldoc ExtUtils::MakeMaker


# --- MakeMaker blibdirs section:
blibdirs : $(INST_LIBDIR)$(DFSEP).exists $(INST_ARCHLIB)$(DFSEP).exists $(INST_AUTODIR)$(DFSEP).exists $(INST_ARCHAUTODIR)$(DFSEP).exists $(INST_BIN)$(DFSEP).exists $(INST_SCRIPT)$(DFSEP).exists $(INST_MAN1DIR)$(DFSEP).exists $(INST_MAN3DIR)$(DFSEP).exists
	$(NOECHO) $(NOOP)

# Backwards compat with 6.18 through 6.25
blibdirs.ts : blibdirs
	$(NOECHO) $(NOOP)

$(INST_LIBDIR)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_LIBDIR)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_LIBDIR)
	$(NOECHO) $(TOUCH) $(INST_LIBDIR)$(DFSEP).exists

$(INST_ARCHLIB)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_ARCHLIB)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_ARCHLIB)
	$(NOECHO) $(TOUCH) $(INST_ARCHLIB)$(DFSEP).exists

$(INST_AUTODIR)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_AUTODIR)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_AUTODIR)
	$(NOECHO) $(TOUCH) $(INST_AUTODIR)$(DFSEP).exists

$(INST_ARCHAUTODIR)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_ARCHAUTODIR)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_ARCHAUTODIR)
	$(NOECHO) $(TOUCH) $(INST_ARCHAUTODIR)$(DFSEP).exists

$(INST_BIN)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_BIN)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_BIN)
	$(NOECHO) $(TOUCH) $(INST_BIN)$(DFSEP).exists

$(INST_SCRIPT)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_SCRIPT)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_SCRIPT)
	$(NOECHO) $(TOUCH) $(INST_SCRIPT)$(DFSEP).exists

$(INST_MAN1DIR)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_MAN1DIR)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_MAN1DIR)
	$(NOECHO) $(TOUCH) $(INST_MAN1DIR)$(DFSEP).exists

$(INST_MAN3DIR)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_MAN3DIR)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_MAN3DIR)
	$(NOECHO) $(TOUCH) $(INST_MAN3DIR)$(DFSEP).exists



# --- MakeMaker linkext section:

linkext :: $(LINKTYPE)
	$(NOECHO) $(NOOP)


# --- MakeMaker dlsyms section:


# --- MakeMaker dynamic_bs section:

BOOTSTRAP =


# --- MakeMaker dynamic section:

dynamic :: $(FIRST_MAKEFILE) $(BOOTSTRAP) $(INST_DYNAMIC)
	$(NOECHO) $(NOOP)


# --- MakeMaker dynamic_lib section:


# --- MakeMaker static section:

## $(INST_PM) has been moved to the all: target.
## It remains here for awhile to allow for old usage: "make static"
static :: $(FIRST_MAKEFILE) $(INST_STATIC)
	$(NOECHO) $(NOOP)


# --- MakeMaker static_lib section:


# --- MakeMaker manifypods section:

POD2MAN_EXE = $(PERLRUN) "-MExtUtils::Command::MM" -e pod2man "--"
POD2MAN = $(POD2MAN_EXE)


manifypods : pure_all  \
	lib/Auth/Schema/Result/UcUser.pm \
	lib/EVCenter.pm \
	lib/EVCenter/Base/ACL.pm \
	lib/EVCenter/Base/Event.pm \
	lib/EVCenter/Controller/Auth.pm \
	lib/EVCenter/Controller/GUI.pm \
	lib/EVCenter/Controller/GUI/Admin.pm \
	lib/EVCenter/Controller/GUI/EventList.pm \
	lib/EVCenter/Controller/Private/event.pm \
	lib/EVCenter/Controller/Private/system.pm \
	lib/EVCenter/Controller/Private/usercontrol.pm \
	lib/EVCenter/Controller/Root.pm \
	lib/EVCenter/Controller/WebServices.pm \
	lib/EVCenter/Includes/Common/Base.pm \
	lib/EVCenter/Includes/Common/Base_OnLoad.pm \
	lib/EVCenter/Includes/SNMPd/Base_OnLoad.pm \
	lib/EVCenter/Model/AuthDB.pm \
	lib/EVCenter/View/HTML.pm \
	lib/EVCenter/View/HTMLBasic.pm \
	lib/EVCenter/View/HTMLNW.pm \
	lib/EVCenter/View/JSON.pm \
	script/evcenter_cgi.pl \
	script/evcenter_create.pl \
	script/evcenter_fastcgi.pl \
	script/evcenter_server.pl \
	script/evcenter_test.pl
	$(NOECHO) $(POD2MAN) --section=1 --perm_rw=$(PERM_RW) -u \
	  script/evcenter_cgi.pl $(INST_MAN1DIR)/evcenter_cgi.pl.$(MAN1EXT) \
	  script/evcenter_create.pl $(INST_MAN1DIR)/evcenter_create.pl.$(MAN1EXT) \
	  script/evcenter_fastcgi.pl $(INST_MAN1DIR)/evcenter_fastcgi.pl.$(MAN1EXT) \
	  script/evcenter_server.pl $(INST_MAN1DIR)/evcenter_server.pl.$(MAN1EXT) \
	  script/evcenter_test.pl $(INST_MAN1DIR)/evcenter_test.pl.$(MAN1EXT) 
	$(NOECHO) $(POD2MAN) --section=3 --perm_rw=$(PERM_RW) -u \
	  lib/Auth/Schema/Result/UcUser.pm $(INST_MAN3DIR)/Auth::Schema::Result::UcUser.$(MAN3EXT) \
	  lib/EVCenter.pm $(INST_MAN3DIR)/EVCenter.$(MAN3EXT) \
	  lib/EVCenter/Base/ACL.pm $(INST_MAN3DIR)/EVCenter::Base::ACL.$(MAN3EXT) \
	  lib/EVCenter/Base/Event.pm $(INST_MAN3DIR)/EVCenter::Base::Event.$(MAN3EXT) \
	  lib/EVCenter/Controller/Auth.pm $(INST_MAN3DIR)/EVCenter::Controller::Auth.$(MAN3EXT) \
	  lib/EVCenter/Controller/GUI.pm $(INST_MAN3DIR)/EVCenter::Controller::GUI.$(MAN3EXT) \
	  lib/EVCenter/Controller/GUI/Admin.pm $(INST_MAN3DIR)/EVCenter::Controller::GUI::Admin.$(MAN3EXT) \
	  lib/EVCenter/Controller/GUI/EventList.pm $(INST_MAN3DIR)/EVCenter::Controller::GUI::EventList.$(MAN3EXT) \
	  lib/EVCenter/Controller/Private/event.pm $(INST_MAN3DIR)/EVCenter::Controller::Private::event.$(MAN3EXT) \
	  lib/EVCenter/Controller/Private/system.pm $(INST_MAN3DIR)/EVCenter::Controller::Private::system.$(MAN3EXT) \
	  lib/EVCenter/Controller/Private/usercontrol.pm $(INST_MAN3DIR)/EVCenter::Controller::Private::usercontrol.$(MAN3EXT) \
	  lib/EVCenter/Controller/Root.pm $(INST_MAN3DIR)/EVCenter::Controller::Root.$(MAN3EXT) \
	  lib/EVCenter/Controller/WebServices.pm $(INST_MAN3DIR)/EVCenter::Controller::WebServices.$(MAN3EXT) \
	  lib/EVCenter/Includes/Common/Base.pm $(INST_MAN3DIR)/EVCenter::Includes::Common::Base.$(MAN3EXT) \
	  lib/EVCenter/Includes/Common/Base_OnLoad.pm $(INST_MAN3DIR)/EVCenter::Includes::Common::Base_OnLoad.$(MAN3EXT) \
	  lib/EVCenter/Includes/SNMPd/Base_OnLoad.pm $(INST_MAN3DIR)/EVCenter::Includes::SNMPd::Base_OnLoad.$(MAN3EXT) \
	  lib/EVCenter/Model/AuthDB.pm $(INST_MAN3DIR)/EVCenter::Model::AuthDB.$(MAN3EXT) \
	  lib/EVCenter/View/HTML.pm $(INST_MAN3DIR)/EVCenter::View::HTML.$(MAN3EXT) \
	  lib/EVCenter/View/HTMLBasic.pm $(INST_MAN3DIR)/EVCenter::View::HTMLBasic.$(MAN3EXT) \
	  lib/EVCenter/View/HTMLNW.pm $(INST_MAN3DIR)/EVCenter::View::HTMLNW.$(MAN3EXT) \
	  lib/EVCenter/View/JSON.pm $(INST_MAN3DIR)/EVCenter::View::JSON.$(MAN3EXT) 




# --- MakeMaker processPL section:


# --- MakeMaker installbin section:

EXE_FILES = script/evcenter_cgi.pl script/evcenter_create.pl script/evcenter_fastcgi.pl script/evcenter_server.pl script/evcenter_test.pl

pure_all :: $(INST_SCRIPT)/evcenter_test.pl $(INST_SCRIPT)/evcenter_server.pl $(INST_SCRIPT)/evcenter_fastcgi.pl $(INST_SCRIPT)/evcenter_create.pl $(INST_SCRIPT)/evcenter_cgi.pl
	$(NOECHO) $(NOOP)

realclean ::
	$(RM_F) \
	  $(INST_SCRIPT)/evcenter_test.pl $(INST_SCRIPT)/evcenter_server.pl \
	  $(INST_SCRIPT)/evcenter_fastcgi.pl $(INST_SCRIPT)/evcenter_create.pl \
	  $(INST_SCRIPT)/evcenter_cgi.pl 

$(INST_SCRIPT)/evcenter_test.pl : script/evcenter_test.pl $(FIRST_MAKEFILE) $(INST_SCRIPT)$(DFSEP).exists $(INST_BIN)$(DFSEP).exists
	$(NOECHO) $(RM_F) $(INST_SCRIPT)/evcenter_test.pl
	$(CP) script/evcenter_test.pl $(INST_SCRIPT)/evcenter_test.pl
	$(FIXIN) $(INST_SCRIPT)/evcenter_test.pl
	-$(NOECHO) $(CHMOD) $(PERM_RWX) $(INST_SCRIPT)/evcenter_test.pl

$(INST_SCRIPT)/evcenter_server.pl : script/evcenter_server.pl $(FIRST_MAKEFILE) $(INST_SCRIPT)$(DFSEP).exists $(INST_BIN)$(DFSEP).exists
	$(NOECHO) $(RM_F) $(INST_SCRIPT)/evcenter_server.pl
	$(CP) script/evcenter_server.pl $(INST_SCRIPT)/evcenter_server.pl
	$(FIXIN) $(INST_SCRIPT)/evcenter_server.pl
	-$(NOECHO) $(CHMOD) $(PERM_RWX) $(INST_SCRIPT)/evcenter_server.pl

$(INST_SCRIPT)/evcenter_fastcgi.pl : script/evcenter_fastcgi.pl $(FIRST_MAKEFILE) $(INST_SCRIPT)$(DFSEP).exists $(INST_BIN)$(DFSEP).exists
	$(NOECHO) $(RM_F) $(INST_SCRIPT)/evcenter_fastcgi.pl
	$(CP) script/evcenter_fastcgi.pl $(INST_SCRIPT)/evcenter_fastcgi.pl
	$(FIXIN) $(INST_SCRIPT)/evcenter_fastcgi.pl
	-$(NOECHO) $(CHMOD) $(PERM_RWX) $(INST_SCRIPT)/evcenter_fastcgi.pl

$(INST_SCRIPT)/evcenter_create.pl : script/evcenter_create.pl $(FIRST_MAKEFILE) $(INST_SCRIPT)$(DFSEP).exists $(INST_BIN)$(DFSEP).exists
	$(NOECHO) $(RM_F) $(INST_SCRIPT)/evcenter_create.pl
	$(CP) script/evcenter_create.pl $(INST_SCRIPT)/evcenter_create.pl
	$(FIXIN) $(INST_SCRIPT)/evcenter_create.pl
	-$(NOECHO) $(CHMOD) $(PERM_RWX) $(INST_SCRIPT)/evcenter_create.pl

$(INST_SCRIPT)/evcenter_cgi.pl : script/evcenter_cgi.pl $(FIRST_MAKEFILE) $(INST_SCRIPT)$(DFSEP).exists $(INST_BIN)$(DFSEP).exists
	$(NOECHO) $(RM_F) $(INST_SCRIPT)/evcenter_cgi.pl
	$(CP) script/evcenter_cgi.pl $(INST_SCRIPT)/evcenter_cgi.pl
	$(FIXIN) $(INST_SCRIPT)/evcenter_cgi.pl
	-$(NOECHO) $(CHMOD) $(PERM_RWX) $(INST_SCRIPT)/evcenter_cgi.pl



# --- MakeMaker subdirs section:

# none

# --- MakeMaker clean_subdirs section:
clean_subdirs :
	$(NOECHO) $(NOOP)


# --- MakeMaker clean section:

# Delete temporary files but do not touch installed files. We don't delete
# the Makefile here so a later make realclean still has a makefile to use.

clean :: clean_subdirs
	- $(RM_F) \
	  $(BASEEXT).bso $(BASEEXT).def \
	  $(BASEEXT).exp $(BASEEXT).x \
	  $(BOOTSTRAP) $(INST_ARCHAUTODIR)/extralibs.all \
	  $(INST_ARCHAUTODIR)/extralibs.ld $(MAKE_APERL_FILE) \
	  *$(LIB_EXT) *$(OBJ_EXT) \
	  *perl.core MYMETA.json \
	  MYMETA.yml blibdirs.ts \
	  core core.*perl.*.? \
	  core.[0-9] core.[0-9][0-9] \
	  core.[0-9][0-9][0-9] core.[0-9][0-9][0-9][0-9] \
	  core.[0-9][0-9][0-9][0-9][0-9] lib$(BASEEXT).def \
	  mon.out perl \
	  perl$(EXE_EXT) perl.exe \
	  perlmain.c pm_to_blib \
	  pm_to_blib.ts so_locations \
	  tmon.out 
	- $(RM_RF) \
	  blib 
	  $(NOECHO) $(RM_F) $(MAKEFILE_OLD)
	- $(MV) $(FIRST_MAKEFILE) $(MAKEFILE_OLD) $(DEV_NULL)


# --- MakeMaker realclean_subdirs section:
realclean_subdirs :
	$(NOECHO) $(NOOP)


# --- MakeMaker realclean section:
# Delete temporary files (via clean) and also delete dist files
realclean purge ::  clean realclean_subdirs
	- $(RM_F) \
	  $(MAKEFILE_OLD) $(FIRST_MAKEFILE) 
	- $(RM_RF) \
	  MYMETA.yml $(DISTVNAME) 


# --- MakeMaker metafile section:
metafile :
	$(NOECHO) $(NOOP)


# --- MakeMaker signature section:
signature :
	cpansign -s


# --- MakeMaker dist_basics section:
distclean :: realclean distcheck
	$(NOECHO) $(NOOP)

distcheck :
	$(PERLRUN) "-MExtUtils::Manifest=fullcheck" -e fullcheck

skipcheck :
	$(PERLRUN) "-MExtUtils::Manifest=skipcheck" -e skipcheck

manifest :
	$(PERLRUN) "-MExtUtils::Manifest=mkmanifest" -e mkmanifest

veryclean : realclean
	$(RM_F) *~ */*~ *.orig */*.orig *.bak */*.bak *.old */*.old



# --- MakeMaker dist_core section:

dist : $(DIST_DEFAULT) $(FIRST_MAKEFILE)
	$(NOECHO) $(ABSPERLRUN) -l -e 'print '\''Warning: Makefile possibly out of date with $(VERSION_FROM)'\''' \
	  -e '    if -e '\''$(VERSION_FROM)'\'' and -M '\''$(VERSION_FROM)'\'' < -M '\''$(FIRST_MAKEFILE)'\'';' --

tardist : $(DISTVNAME).tar$(SUFFIX)
	$(NOECHO) $(NOOP)

uutardist : $(DISTVNAME).tar$(SUFFIX)
	uuencode $(DISTVNAME).tar$(SUFFIX) $(DISTVNAME).tar$(SUFFIX) > $(DISTVNAME).tar$(SUFFIX)_uu
	$(NOECHO) $(ECHO) 'Created $(DISTVNAME).tar$(SUFFIX)_uu'

$(DISTVNAME).tar$(SUFFIX) : distdir
	$(PREOP)
	$(TO_UNIX)
	$(TAR) $(TARFLAGS) $(DISTVNAME).tar $(DISTVNAME)
	$(RM_RF) $(DISTVNAME)
	$(COMPRESS) $(DISTVNAME).tar
	$(NOECHO) $(ECHO) 'Created $(DISTVNAME).tar$(SUFFIX)'
	$(POSTOP)

zipdist : $(DISTVNAME).zip
	$(NOECHO) $(NOOP)

$(DISTVNAME).zip : distdir
	$(PREOP)
	$(ZIP) $(ZIPFLAGS) $(DISTVNAME).zip $(DISTVNAME)
	$(RM_RF) $(DISTVNAME)
	$(NOECHO) $(ECHO) 'Created $(DISTVNAME).zip'
	$(POSTOP)

shdist : distdir
	$(PREOP)
	$(SHAR) $(DISTVNAME) > $(DISTVNAME).shar
	$(RM_RF) $(DISTVNAME)
	$(NOECHO) $(ECHO) 'Created $(DISTVNAME).shar'
	$(POSTOP)


# --- MakeMaker distdir section:
create_distdir :
	$(RM_RF) $(DISTVNAME)
	$(PERLRUN) "-MExtUtils::Manifest=manicopy,maniread" \
		-e "manicopy(maniread(),'$(DISTVNAME)', '$(DIST_CP)');"

distdir : create_distdir  
	$(NOECHO) $(NOOP)



# --- MakeMaker dist_test section:
disttest : distdir
	cd $(DISTVNAME) && $(ABSPERLRUN) Makefile.PL 
	cd $(DISTVNAME) && $(MAKE) $(PASTHRU)
	cd $(DISTVNAME) && $(MAKE) test $(PASTHRU)



# --- MakeMaker dist_ci section:

ci :
	$(PERLRUN) "-MExtUtils::Manifest=maniread" \
	  -e "@all = keys %{ maniread() };" \
	  -e "print(qq{Executing $(CI) @all\n}); system(qq{$(CI) @all});" \
	  -e "print(qq{Executing $(RCS_LABEL) ...\n}); system(qq{$(RCS_LABEL) @all});"


# --- MakeMaker distmeta section:
distmeta : create_distdir metafile
	$(NOECHO) cd $(DISTVNAME) && $(ABSPERLRUN) -MExtUtils::Manifest=maniadd -e 'exit unless -e q{META.yml};' \
	  -e 'eval { maniadd({q{META.yml} => q{Module YAML meta-data (added by MakeMaker)}}) }' \
	  -e '    or print "Could not add META.yml to MANIFEST: $$$${'\''@'\''}\n"' --
	$(NOECHO) cd $(DISTVNAME) && $(ABSPERLRUN) -MExtUtils::Manifest=maniadd -e 'exit unless -f q{META.json};' \
	  -e 'eval { maniadd({q{META.json} => q{Module JSON meta-data (added by MakeMaker)}}) }' \
	  -e '    or print "Could not add META.json to MANIFEST: $$$${'\''@'\''}\n"' --



# --- MakeMaker distsignature section:
distsignature : create_distdir
	$(NOECHO) cd $(DISTVNAME) && $(ABSPERLRUN) -MExtUtils::Manifest=maniadd -e 'eval { maniadd({q{SIGNATURE} => q{Public-key signature (added by MakeMaker)}}) }' \
	  -e '    or print "Could not add SIGNATURE to MANIFEST: $$$${'\''@'\''}\n"' --
	$(NOECHO) cd $(DISTVNAME) && $(TOUCH) SIGNATURE
	cd $(DISTVNAME) && cpansign -s



# --- MakeMaker install section:

install :: pure_install doc_install
	$(NOECHO) $(NOOP)

install_perl :: pure_perl_install doc_perl_install
	$(NOECHO) $(NOOP)

install_site :: pure_site_install doc_site_install
	$(NOECHO) $(NOOP)

install_vendor :: pure_vendor_install doc_vendor_install
	$(NOECHO) $(NOOP)

pure_install :: pure_$(INSTALLDIRS)_install
	$(NOECHO) $(NOOP)

doc_install :: doc_$(INSTALLDIRS)_install
	$(NOECHO) $(NOOP)

pure__install : pure_site_install
	$(NOECHO) $(ECHO) INSTALLDIRS not defined, defaulting to INSTALLDIRS=site

doc__install : doc_site_install
	$(NOECHO) $(ECHO) INSTALLDIRS not defined, defaulting to INSTALLDIRS=site

pure_perl_install :: all
	$(NOECHO) $(MOD_INSTALL) \
		read "$(PERL_ARCHLIB)/auto/$(FULLEXT)/.packlist" \
		write "$(DESTINSTALLARCHLIB)/auto/$(FULLEXT)/.packlist" \
		"$(INST_LIB)" "$(DESTINSTALLPRIVLIB)" \
		"$(INST_ARCHLIB)" "$(DESTINSTALLARCHLIB)" \
		"$(INST_BIN)" "$(DESTINSTALLBIN)" \
		"$(INST_SCRIPT)" "$(DESTINSTALLSCRIPT)" \
		"$(INST_MAN1DIR)" "$(DESTINSTALLMAN1DIR)" \
		"$(INST_MAN3DIR)" "$(DESTINSTALLMAN3DIR)"
	$(NOECHO) $(WARN_IF_OLD_PACKLIST) \
		"$(SITEARCHEXP)/auto/$(FULLEXT)"


pure_site_install :: all
	$(NOECHO) $(MOD_INSTALL) \
		read "$(SITEARCHEXP)/auto/$(FULLEXT)/.packlist" \
		write "$(DESTINSTALLSITEARCH)/auto/$(FULLEXT)/.packlist" \
		"$(INST_LIB)" "$(DESTINSTALLSITELIB)" \
		"$(INST_ARCHLIB)" "$(DESTINSTALLSITEARCH)" \
		"$(INST_BIN)" "$(DESTINSTALLSITEBIN)" \
		"$(INST_SCRIPT)" "$(DESTINSTALLSITESCRIPT)" \
		"$(INST_MAN1DIR)" "$(DESTINSTALLSITEMAN1DIR)" \
		"$(INST_MAN3DIR)" "$(DESTINSTALLSITEMAN3DIR)"
	$(NOECHO) $(WARN_IF_OLD_PACKLIST) \
		"$(PERL_ARCHLIB)/auto/$(FULLEXT)"

pure_vendor_install :: all
	$(NOECHO) $(MOD_INSTALL) \
		read "$(VENDORARCHEXP)/auto/$(FULLEXT)/.packlist" \
		write "$(DESTINSTALLVENDORARCH)/auto/$(FULLEXT)/.packlist" \
		"$(INST_LIB)" "$(DESTINSTALLVENDORLIB)" \
		"$(INST_ARCHLIB)" "$(DESTINSTALLVENDORARCH)" \
		"$(INST_BIN)" "$(DESTINSTALLVENDORBIN)" \
		"$(INST_SCRIPT)" "$(DESTINSTALLVENDORSCRIPT)" \
		"$(INST_MAN1DIR)" "$(DESTINSTALLVENDORMAN1DIR)" \
		"$(INST_MAN3DIR)" "$(DESTINSTALLVENDORMAN3DIR)"


doc_perl_install :: all
	$(NOECHO) $(ECHO) Appending installation info to "$(DESTINSTALLARCHLIB)/perllocal.pod"
	-$(NOECHO) $(MKPATH) "$(DESTINSTALLARCHLIB)"
	-$(NOECHO) $(DOC_INSTALL) \
		"Module" "$(NAME)" \
		"installed into" $(INSTALLPRIVLIB) \
		LINKTYPE "$(LINKTYPE)" \
		VERSION "$(VERSION)" \
		EXE_FILES "$(EXE_FILES)" \
		>> "$(DESTINSTALLARCHLIB)/perllocal.pod"

doc_site_install :: all
	$(NOECHO) $(ECHO) Appending installation info to "$(DESTINSTALLARCHLIB)/perllocal.pod"
	-$(NOECHO) $(MKPATH) "$(DESTINSTALLARCHLIB)"
	-$(NOECHO) $(DOC_INSTALL) \
		"Module" "$(NAME)" \
		"installed into" $(INSTALLSITELIB) \
		LINKTYPE "$(LINKTYPE)" \
		VERSION "$(VERSION)" \
		EXE_FILES "$(EXE_FILES)" \
		>> "$(DESTINSTALLARCHLIB)/perllocal.pod"

doc_vendor_install :: all
	$(NOECHO) $(ECHO) Appending installation info to "$(DESTINSTALLARCHLIB)/perllocal.pod"
	-$(NOECHO) $(MKPATH) "$(DESTINSTALLARCHLIB)"
	-$(NOECHO) $(DOC_INSTALL) \
		"Module" "$(NAME)" \
		"installed into" $(INSTALLVENDORLIB) \
		LINKTYPE "$(LINKTYPE)" \
		VERSION "$(VERSION)" \
		EXE_FILES "$(EXE_FILES)" \
		>> "$(DESTINSTALLARCHLIB)/perllocal.pod"


uninstall :: uninstall_from_$(INSTALLDIRS)dirs
	$(NOECHO) $(NOOP)

uninstall_from_perldirs ::
	$(NOECHO) $(UNINSTALL) "$(PERL_ARCHLIB)/auto/$(FULLEXT)/.packlist"

uninstall_from_sitedirs ::
	$(NOECHO) $(UNINSTALL) "$(SITEARCHEXP)/auto/$(FULLEXT)/.packlist"

uninstall_from_vendordirs ::
	$(NOECHO) $(UNINSTALL) "$(VENDORARCHEXP)/auto/$(FULLEXT)/.packlist"


# --- MakeMaker force section:
# Phony target to force checking subdirectories.
FORCE :
	$(NOECHO) $(NOOP)


# --- MakeMaker perldepend section:


# --- MakeMaker makefile section:
# We take a very conservative approach here, but it's worth it.
# We move Makefile to Makefile.old here to avoid gnu make looping.
$(FIRST_MAKEFILE) : Makefile.PL $(CONFIGDEP)
	$(NOECHO) $(ECHO) "Makefile out-of-date with respect to $?"
	$(NOECHO) $(ECHO) "Cleaning current config before rebuilding Makefile..."
	-$(NOECHO) $(RM_F) $(MAKEFILE_OLD)
	-$(NOECHO) $(MV)   $(FIRST_MAKEFILE) $(MAKEFILE_OLD)
	- $(MAKE) $(USEMAKEFILE) $(MAKEFILE_OLD) clean $(DEV_NULL)
	$(PERLRUN) Makefile.PL 
	$(NOECHO) $(ECHO) "==> Your Makefile has been rebuilt. <=="
	$(NOECHO) $(ECHO) "==> Please rerun the $(MAKE) command.  <=="
	$(FALSE)



# --- MakeMaker staticmake section:

# --- MakeMaker makeaperl section ---
MAP_TARGET    = perl
FULLPERL      = "/usr/bin/perl"

$(MAP_TARGET) :: static $(MAKE_APERL_FILE)
	$(MAKE) $(USEMAKEFILE) $(MAKE_APERL_FILE) $@

$(MAKE_APERL_FILE) : $(FIRST_MAKEFILE) pm_to_blib
	$(NOECHO) $(ECHO) Writing \"$(MAKE_APERL_FILE)\" for this $(MAP_TARGET)
	$(NOECHO) $(PERLRUNINST) \
		Makefile.PL DIR="" \
		MAKEFILE=$(MAKE_APERL_FILE) LINKTYPE=static \
		MAKEAPERL=1 NORECURS=1 CCCDLFLAGS=


# --- MakeMaker test section:

TEST_VERBOSE=0
TEST_TYPE=test_$(LINKTYPE)
TEST_FILE = test.pl
TEST_FILES = t/controller_GUI-Admin.t t/controller_GUI-Auth.t t/controller_GUI-Authenticate.t t/controller_GUI.t t/controller_Private-system.t t/controller_Private-usercontrol.t t/model_AuthDB.t t/model_Processor.t t/model_UserControl.t t/view_HTMLBasic.t t/view_HTMLNW.t
TESTDB_SW = -d

testdb :: testdb_$(LINKTYPE)

test :: $(TEST_TYPE) subdirs-test

subdirs-test ::
	$(NOECHO) $(NOOP)


test_dynamic :: pure_all
	PERL_DL_NONLAZY=1 $(FULLPERLRUN) "-MExtUtils::Command::MM" "-MTest::Harness" "-e" "undef *Test::Harness::Switches; test_harness($(TEST_VERBOSE), 'inc', '$(INST_LIB)', '$(INST_ARCHLIB)')" $(TEST_FILES)

testdb_dynamic :: pure_all
	PERL_DL_NONLAZY=1 $(FULLPERLRUN) $(TESTDB_SW) "-Iinc" "-I$(INST_LIB)" "-I$(INST_ARCHLIB)" $(TEST_FILE)

test_ : test_dynamic

test_static :: test_dynamic
testdb_static :: testdb_dynamic


# --- MakeMaker ppd section:
# Creates a PPD (Perl Package Description) for a binary distribution.
ppd :
	$(NOECHO) $(ECHO) '<SOFTPKG NAME="$(DISTNAME)" VERSION="$(VERSION)">' > $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '    <ABSTRACT>Catalyst based application</ABSTRACT>' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '    <AUTHOR>JoÃ£o AndrÃ© Simioni</AUTHOR>' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '    <IMPLEMENTATION>' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Catalyst::Action::RenderView" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Catalyst::Authentication::Store::DBIx::Class" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Catalyst::Model::Adaptor" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Catalyst::Plugin::Compress" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Catalyst::Plugin::ConfigLoader" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Catalyst::Plugin::Server::JSONRPC" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Catalyst::Plugin::Session::State::Stash" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Catalyst::Plugin::Session::Store::File" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Catalyst::Plugin::SmartURI" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Catalyst::Plugin::Static::Simple" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Catalyst::Plugin::Unicode" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Catalyst::Runtime" VERSION="5.90042" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Catalyst::View::JSON" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Catalyst::View::TT" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Config::General" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="DBD::Pg" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="DBIx::Connector" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Hash::Merge::Simple" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="JSON::MaybeXS" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Log::Any::Adapter::Catalyst" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Module::Pluggable::Object" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Moose::" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Net::SNMP" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="SQL::Abstract::More" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="common::sense" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="namespace::autoclean" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <ARCHITECTURE NAME="x86_64-linux-thread-multi-5.10" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <CODEBASE HREF="" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '    </IMPLEMENTATION>' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '</SOFTPKG>' >> $(DISTNAME).ppd


# --- MakeMaker pm_to_blib section:

pm_to_blib : $(FIRST_MAKEFILE) $(TO_INST_PM)
	$(NOECHO) $(ABSPERLRUN) -MExtUtils::Install -e 'pm_to_blib({@ARGV}, '\''$(INST_LIB)/auto'\'', q[$(PM_FILTER)], '\''$(PERM_DIR)'\'')' -- \
	  lib/Auth/Schema.pm blib/lib/Auth/Schema.pm \
	  lib/Auth/Schema/Result/UcUser.pm blib/lib/Auth/Schema/Result/UcUser.pm \
	  lib/EVCenter.pm blib/lib/EVCenter.pm \
	  lib/EVCenter/Base/ACL.pm blib/lib/EVCenter/Base/ACL.pm \
	  lib/EVCenter/Base/Event.pm blib/lib/EVCenter/Base/Event.pm \
	  lib/EVCenter/Base/Event/Processor.pm blib/lib/EVCenter/Base/Event/Processor.pm \
	  lib/EVCenter/Base/Event/Processor/Common.pm blib/lib/EVCenter/Base/Event/Processor/Common.pm \
	  lib/EVCenter/Base/Event/Processor/Default.pm blib/lib/EVCenter/Base/Event/Processor/Default.pm \
	  lib/EVCenter/Base/Event/Processor/SNMPd.pm blib/lib/EVCenter/Base/Event/Processor/SNMPd.pm \
	  lib/EVCenter/Base/UserControl.pm blib/lib/EVCenter/Base/UserControl.pm \
	  lib/EVCenter/Controller/Auth.pm blib/lib/EVCenter/Controller/Auth.pm \
	  lib/EVCenter/Controller/GUI.pm blib/lib/EVCenter/Controller/GUI.pm \
	  lib/EVCenter/Controller/GUI/Admin.pm blib/lib/EVCenter/Controller/GUI/Admin.pm \
	  lib/EVCenter/Controller/GUI/EventList.pm blib/lib/EVCenter/Controller/GUI/EventList.pm \
	  lib/EVCenter/Controller/Private/event.pm blib/lib/EVCenter/Controller/Private/event.pm \
	  lib/EVCenter/Controller/Private/system.pm blib/lib/EVCenter/Controller/Private/system.pm \
	  lib/EVCenter/Controller/Private/usercontrol.pm blib/lib/EVCenter/Controller/Private/usercontrol.pm \
	  lib/EVCenter/Controller/Root.pm blib/lib/EVCenter/Controller/Root.pm \
	  lib/EVCenter/Controller/WebServices.pm blib/lib/EVCenter/Controller/WebServices.pm \
	  lib/EVCenter/Includes/Common/Base.pm blib/lib/EVCenter/Includes/Common/Base.pm \
	  lib/EVCenter/Includes/Common/Base_OnLoad.pm blib/lib/EVCenter/Includes/Common/Base_OnLoad.pm \
	  lib/EVCenter/Includes/SNMPd/Base.pm blib/lib/EVCenter/Includes/SNMPd/Base.pm \
	  lib/EVCenter/Includes/SNMPd/Base_OnLoad.pm blib/lib/EVCenter/Includes/SNMPd/Base_OnLoad.pm \
	  lib/EVCenter/Model/ACL.pm blib/lib/EVCenter/Model/ACL.pm \
	  lib/EVCenter/Model/AuthDB.pm blib/lib/EVCenter/Model/AuthDB.pm \
	  lib/EVCenter/Model/Event.pm blib/lib/EVCenter/Model/Event.pm \
	  lib/EVCenter/Model/Processor.pm blib/lib/EVCenter/Model/Processor.pm \
	  lib/EVCenter/Model/UserControl.pm blib/lib/EVCenter/Model/UserControl.pm \
	  lib/EVCenter/View/HTML.pm blib/lib/EVCenter/View/HTML.pm \
	  lib/EVCenter/View/HTMLBasic.pm blib/lib/EVCenter/View/HTMLBasic.pm \
	  lib/EVCenter/View/HTMLNW.pm blib/lib/EVCenter/View/HTMLNW.pm \
	  lib/EVCenter/View/JSON.pm blib/lib/EVCenter/View/JSON.pm 
	$(NOECHO) $(TOUCH) pm_to_blib


# --- MakeMaker selfdocument section:


# --- MakeMaker postamble section:


# End.
# Postamble by Module::Install 1.16
# --- Module::Install::Admin::Makefile section:

realclean purge ::
	$(RM_F) $(DISTVNAME).tar$(SUFFIX)
	$(RM_F) MANIFEST.bak _build
	$(PERL) "-Ilib" "-MModule::Install::Admin" -e "remove_meta()"
	$(RM_RF) inc

reset :: purge

upload :: test dist
	cpan-upload -verbose $(DISTVNAME).tar$(SUFFIX)

grok ::
	perldoc Module::Install

distsign ::
	cpansign -s

catalyst_par :: all
	$(NOECHO) $(PERL) -Ilib -Minc::Module::Install -MModule::Install::Catalyst -e"Catalyst::Module::Install::_catalyst_par( '', 'EVCenter', { CLASSES => [], PAROPTS =>  {}, ENGINE => 'CGI', SCRIPT => '', USAGE => q## } )"
# --- Module::Install::AutoInstall section:

config :: installdeps
	$(NOECHO) $(NOOP)

checkdeps ::
	$(PERL) Makefile.PL --checkdeps

installdeps ::
	$(PERL) Makefile.PL --config= --installdeps=Catalyst::Runtime,5.90042,Catalyst::Plugin::Server::JSONRPC,0,Catalyst::Plugin::SmartURI,0,Catalyst::Plugin::Unicode,0,Catalyst::View::TT,0,Catalyst::Authentication::Store::DBIx::Class,0,Catalyst::Plugin::Compress,0,Catalyst::Plugin::Session::Store::File,0,Catalyst::Plugin::Session::State::Stash,0,Catalyst::Model::Adaptor,0,Catalyst::View::JSON,0,DBD::Pg,0,Net::SNMP,0,DBIx::Connector,0,SQL::Abstract::More,0,Log::Any::Adapter::Catalyst,0,JSON::MaybeXS,0,Hash::Merge::Simple,0

installdeps_notest ::
	$(PERL) Makefile.PL --config=notest,1 --installdeps=Catalyst::Runtime,5.90042,Catalyst::Plugin::Server::JSONRPC,0,Catalyst::Plugin::SmartURI,0,Catalyst::Plugin::Unicode,0,Catalyst::View::TT,0,Catalyst::Authentication::Store::DBIx::Class,0,Catalyst::Plugin::Compress,0,Catalyst::Plugin::Session::Store::File,0,Catalyst::Plugin::Session::State::Stash,0,Catalyst::Model::Adaptor,0,Catalyst::View::JSON,0,DBD::Pg,0,Net::SNMP,0,DBIx::Connector,0,SQL::Abstract::More,0,Log::Any::Adapter::Catalyst,0,JSON::MaybeXS,0,Hash::Merge::Simple,0

upgradedeps ::
	$(PERL) Makefile.PL --config= --upgradedeps=Catalyst::Runtime,5.90042,Catalyst::Plugin::Server::JSONRPC,0,Catalyst::Plugin::SmartURI,0,Catalyst::Plugin::Unicode,0,Catalyst::View::TT,0,Catalyst::Authentication::Store::DBIx::Class,0,Catalyst::Plugin::Compress,0,Catalyst::Plugin::Session::Store::File,0,Catalyst::Plugin::Session::State::Stash,0,Catalyst::Model::Adaptor,0,Catalyst::View::JSON,0,DBD::Pg,0,Net::SNMP,0,DBIx::Connector,0,SQL::Abstract::More,0,Log::Any::Adapter::Catalyst,0,JSON::MaybeXS,0,Hash::Merge::Simple,0,Test::More,0.88,Catalyst::Plugin::ConfigLoader,0,Catalyst::Plugin::Static::Simple,0,Catalyst::Action::RenderView,0,Moose,0,common::sense,0,namespace::autoclean,0,Config::General,0,Module::Pluggable::Object,0

upgradedeps_notest ::
	$(PERL) Makefile.PL --config=notest,1 --upgradedeps=Catalyst::Runtime,5.90042,Catalyst::Plugin::Server::JSONRPC,0,Catalyst::Plugin::SmartURI,0,Catalyst::Plugin::Unicode,0,Catalyst::View::TT,0,Catalyst::Authentication::Store::DBIx::Class,0,Catalyst::Plugin::Compress,0,Catalyst::Plugin::Session::Store::File,0,Catalyst::Plugin::Session::State::Stash,0,Catalyst::Model::Adaptor,0,Catalyst::View::JSON,0,DBD::Pg,0,Net::SNMP,0,DBIx::Connector,0,SQL::Abstract::More,0,Log::Any::Adapter::Catalyst,0,JSON::MaybeXS,0,Hash::Merge::Simple,0,Test::More,0.88,Catalyst::Plugin::ConfigLoader,0,Catalyst::Plugin::Static::Simple,0,Catalyst::Action::RenderView,0,Moose,0,common::sense,0,namespace::autoclean,0,Config::General,0,Module::Pluggable::Object,0

listdeps ::
	@$(PERL) -le "print for @ARGV" Catalyst::Runtime Catalyst::Plugin::Server::JSONRPC Catalyst::Plugin::SmartURI Catalyst::Plugin::Unicode Catalyst::View::TT Catalyst::Authentication::Store::DBIx::Class Catalyst::Plugin::Compress Catalyst::Plugin::Session::Store::File Catalyst::Plugin::Session::State::Stash Catalyst::Model::Adaptor Catalyst::View::JSON DBD::Pg Net::SNMP DBIx::Connector SQL::Abstract::More Log::Any::Adapter::Catalyst JSON::MaybeXS Hash::Merge::Simple

listalldeps ::
	@$(PERL) -le "print for @ARGV" Catalyst::Runtime Catalyst::Plugin::Server::JSONRPC Catalyst::Plugin::SmartURI Catalyst::Plugin::Unicode Catalyst::View::TT Catalyst::Authentication::Store::DBIx::Class Catalyst::Plugin::Compress Catalyst::Plugin::Session::Store::File Catalyst::Plugin::Session::State::Stash Catalyst::Model::Adaptor Catalyst::View::JSON DBD::Pg Net::SNMP DBIx::Connector SQL::Abstract::More Log::Any::Adapter::Catalyst JSON::MaybeXS Hash::Merge::Simple Test::More Catalyst::Plugin::ConfigLoader Catalyst::Plugin::Static::Simple Catalyst::Action::RenderView Moose common::sense namespace::autoclean Config::General Module::Pluggable::Object

