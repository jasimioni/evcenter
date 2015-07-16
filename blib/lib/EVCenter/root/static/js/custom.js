/* JS */

/* $.hash jQuery Extension

  Allows it to change location URL to include / exclude or change a parameter.

*/

(function ( $ ) {
    $.urlparms = {
        add: function(nkey, nvalue) {
            var sPageURL = window.location.search.substring(1);
            var newParams = [];
            var changed   = 0;

            var sURLVariables = sPageURL.split('&');
            if (sURLVariables[0] == '') {
              sURLVariables.shift();
            }
            for (var i = 0; i < sURLVariables.length; i++) {
              var sParameterName = sURLVariables[i].split('=');
              if (sParameterName[0] == nkey) {
                sURLVariables[i] = nkey + '=' + nvalue;
                changed = 1;
              }
            }

            if (changed == 0) {
                sURLVariables.push(nkey + '=' + nvalue);
            }
            console.log(window.location.pathname + '?' + sURLVariables.join('&'));
            history.pushState({}, "View Filter Change", window.location.pathname + '?' + sURLVariables.join('&'));
        },
        del: function(nkey) {
            var sPageURL = window.location.search.substring(1);
            var newParams = [];
            var splice = -1;

            var sURLVariables = sPageURL.split('&');
            if (sURLVariables[0] == '') {
              sURLVariables.shift();
            }
            for (var i = 0; i < sURLVariables.length; i++) {
              var sParameterName = sURLVariables[i].split('=');
              if (sParameterName[0] == nkey) {
                splice = i;
              }
            }

            if (splice >= 0) {
              sURLVariables.splice(splice, 1);
            }
            history.pushState({}, "View Filter Change", window.location.pathname + '?' + sURLVariables.join('&'));
        },
    };
}( jQuery ));


/* Navigation */

$(document).ready(function(){

  $(window).resize(function()
  {
    if($(window).width() >= 765){
      $(".sidebar #nav").slideDown(350);
    }
    else{
      $(".sidebar #nav").slideUp(350); 
    }
  });
  
   $(".has_sub > a").click(function(e){
    e.preventDefault();
    var menu_li = $(this).parent("li");
    var menu_ul = $(this).next("ul");

    if(menu_li.hasClass("open")){
      menu_ul.slideUp(350);
      menu_li.removeClass("open")
    }
    else{
      $("#nav > li > ul").slideUp(350);
      $("#nav > li").removeClass("open");
      menu_ul.slideDown(350);
      menu_li.addClass("open");
    }
  });
});

$(document).ready(function(){
  $(".sidebar-dropdown a").on('click',function(e){
      e.preventDefault();

      if(!$(this).hasClass("open")) {
        // hide any open menus and remove all other classes
        $(".sidebar #nav").slideUp(350);
        $(".sidebar-dropdown a").removeClass("open");
        
        // open our new menu and add the open class
        $(".sidebar #nav").slideDown(350);
        $(this).addClass("open");
      }
      
      else if($(this).hasClass("open")) {
        $(this).removeClass("open");
        $(".sidebar #nav").slideUp(350);
      }
  });

});

/* Widget close */

$('.wclose').click(function(e){
  e.preventDefault();
  var $wbox = $(this).parent().parent().parent();
  $wbox.hide(100);
});

/* Widget minimize */

$('.wminimize').click(function(e){
	e.preventDefault();
	var $wcontent = $(this).parent().parent().next('.widget-content');
	if($wcontent.is(':visible')) 
	{
	  $(this).children('i').removeClass('fa fa-chevron-up');
	  $(this).children('i').addClass('fa fa-chevron-down');
	}
	else 
	{
	  $(this).children('i').removeClass('fa fa-chevron-down');
	  $(this).children('i').addClass('fa fa-chevron-up');
	}            
	$wcontent.toggle(500);
}); 

/* Progressbar animation */

setTimeout(function(){

	$('.progress-animated .progress-bar').each(function() {
		var me = $(this);
		var perc = me.attr("data-percentage");

		//TODO: left and right text handling

		var current_perc = 0;

		var progress = setInterval(function() {
			if (current_perc>=perc) {
				clearInterval(progress);
			} else {
				current_perc +=1;
				me.css('width', (current_perc)+'%');
			}

			me.text((current_perc)+'%');

		}, 200);

	});

},1200);

/* Scroll to Top */

$(".totop").hide();

$(function(){
	$(window).scroll(function(){
	  if ($(this).scrollTop()>300)
	  {
		$('.totop').fadeIn();
	  } 
	  else
	  {
		$('.totop').fadeOut();
	  }
	});

	$('.totop a').click(function (e) {
	  e.preventDefault();
	  $('body,html').animate({scrollTop: 0}, 500);
	});

});

/* On Off pllugin */  
  
$(document).ready(function() {
  $('.toggleBtn').onoff();
});


/* CL Editor */

$(".cleditor").cleditor({
    width: "auto",
    height: "auto"
});

/* Modal fix */

$('.modal').appendTo($('body'));

/* Pretty Photo for Gallery*/

jQuery("a[class^='prettyPhoto']").prettyPhoto({
overlay_gallery: false, social_tools: false
});

/* Slim Scroll */

/* Slim scroll for chat widget */

$('.scroll-chat').slimscroll({
  height: '350px',
  color: 'rgba(0,0,0,0.3)',
  size: '5px'
});

