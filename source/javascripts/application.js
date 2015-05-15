/* Application JS: */

//= require "html5"
//= require "jquery-1.10.2"
//= require "bootstrap"
//= require "owl.carousel"
//= require "jquery.nouislider.all"
//= require "hooch"

$(document).ready(function() {

  //Explore Flyout
  $('.btn-slide').click(function() {
    var whichSlide = ".slide-" + $(this).data('slide');
    $('.cover').addClass('active');
    $('.slide-content').addClass('active');
    // hide header nav while explore tab is open
    // $('.site-header').hide();
    // add content-open class for explore width -- see site.css.scss to adjust width
    // $('body').addClass('content-open');
    // fade in content
    // $(whichSlide).addClass('active');
    // lock background to prevent it from scrolling during explore interaction
    // $('.page-wrapper').css('position', 'fixed');
    if(whichSlide = ".slide-slideshow") {
      var owl = $(".owl-carousel"),
      status = $(".slide-number");

      owl.owlCarousel({
        navigation : true, // Show next and prev buttons
        navigationText: ["<i class=\"fa fa-angle-left\"></i>","<i class=\"fa fa-angle-right\"></i>"],
        slideSpeed : 300,
        pagination : false,
        singleItem : true,
        items : 1,
        itemsScaleUp : true,
        afterAction : afterAction
      });
     
      function updateResult(pos,value){
        status.find(pos).text(value);
      }
     
      function afterAction(){
        updateResult(".owlItems", this.owl.owlItems.length);
        updateResult(".currentItem", this.owl.currentItem + 1);
      }
    };
  });
  $('.close-drawer-button').click(function() {
    // remove content open class
    // $('body').removeClass('content-open');
    // unlock background to enable scrolling
    // $('.page-wrapper').css('position', 'relative');
    // fade header nav back in
    $('.site-header').show();
    //resets body to top of window -- fixes a strange scrolling issue
    // $('body').scrollTop(0);
    // fade out content
    // $('.slide-content-wrapper').removeClass('active');
    $('.cover').removeClass('active');
    $('.slide-content').removeClass('active');
  });

  $(".home-carousel").owlCarousel({
    autoPlay: true,
    navigation : false, // Show next and prev buttons
    slideSpeed : 300,
    paginationSpeed : 700,
    pagination : false,
    items : 5,
    itemsScaleUp : true
  });

  $('#view-amenities').click(function() {
    if ($('.all-amenities').is(':visible')) {
      $('#view-amenities').html("View All Amenities");
      $('.all-amenities').slideUp();
    } else {
      $('#view-amenities').html("Hide All Amenities");
      $('.all-amenities').slideDown();
    };
  });

  $('.nav-toggle').click(function() {
    if ($('.main-nav').hasClass('active')) {
      $('.main-nav').hide();
      $('.main-nav').removeClass('active');
    } else {
      $('.main-nav').show();
      $('.main-nav').addClass('active');
    }
  });

  //Explore tab navigation
  $('.tab-toggle').click(function() {
    // Clear active classes
    $('.tab-pane').removeClass('pane-active');
    $('.tab-nav').removeClass('tab-active');

    // Set triggers
    if ($(this).attr('data-group')) {
      var paneID = $(this).attr('href');
      var tabID = $(this).attr('data-group');
    } else {
      var paneID = '#' + $(this).attr('data-toggle');
      var tabID = $(this).attr('data-toggle');
    }

    // Set active classes
    $('.tab-nav[data-toggle=' + tabID + ']').addClass('tab-active');
    $(paneID).addClass('pane-active');
  });

  // Debounce Function -- Can be used anywhere debouncing is required
  function debounce(func, wait, immediate) {
    var timeout;
    return function() {
      var context = this, args = arguments;
      var later = function() {
        timeout = null;
        if (!immediate) func.apply(context, args);
      };
      var callNow = immediate && !timeout;
      clearTimeout(timeout);
      timeout = setTimeout(later, wait);
      if (callNow) func.apply(context, args);
    };
  };

  //Scroll-synced Hide and Show Navigation
  var lastScrollTop = 0;
  var myEfficientFn = debounce(function () {
  var st = $(this).scrollTop();
  var navbarHeight = $('.site-header').outerHeight();
  if (st > lastScrollTop && st > navbarHeight) {
    $('.site-header').addClass('nav-hide');
    if ($('.main-nav').hasClass('active')) {
      $('.main-nav').hide();
      $('.main-nav').removeClass('active');
    }
   } else {
    $('.site-header').removeClass('nav-hide');
   }
   lastScrollTop = st;
  }, 20);

  window.addEventListener('scroll', myEfficientFn);

  // Location Tabbed Map Overlay
  $('.location-toggle').click(function(e) {
    e.preventDefault();
    // Retrieve name of current location
    var data = $('.location-info-wrapper .active').data('location');
    // Set associated tab name
    var locationTab = $(this).data('toggle');
    // Hide all tabs for active window
    $('.location-info-wrapper .active .location-tab').hide();
    // Remove active from nav link
    $('.location-toggle.active').removeClass('active');
    // Add Active Class to active link for styling
    $(this).addClass('active');
    // Show requested Tab
    $('.location-info-wrapper .active .tab-' + locationTab).show();
  });

  $('#location-close-btn').click(function(e) {
    e.preventDefault();
    // Hide Any Open Windows and tabs
    $('.location-info-wrapper .active .location-tab').hide();
    $('.location-info-wrapper .active.map-location').hide();
    $('.location-info-wrapper').hide();
    // Remove Active class
    $('.location-info-wrapper .active').removeClass('active');
  });

  $('#sliderPrice').noUiSlider({
    start: [ 450, 1500 ],
    connect: true,
    range: {
      'min': 100,
      'max': 2000
    },
    format: wNumb({
      decimals: 0,
      prefix: '$',
    })
  });

  $('#sliderPrice').Link('lower').to($('#slider-lower'));
  $('#sliderPrice').Link('upper').to($('#slider-upper'));

});