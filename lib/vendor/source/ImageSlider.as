package  
{
	import caurina.transitions.properties.ColorShortcuts;
	import caurina.transitions.Tweener;
	import fl.motion.Color;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.ColorTransform;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	import flash.net.navigateToURL;


	public class ImageSlider extends MovieClip
	{
		//Array holding imageData objects
		private var images:Array;
		
		//Slide width
		private var slideWidth:Number = 400;
		
		//Slide height
		private var slideHeight:Number = 300;
		
		//Counter for loading
		private var loadCounter:int = 0;
		
		//Loader instance
		private var imageLoader:Loader;
		
		//Array holding the slide clips
		private var slides:Array;
		
		//Index of the current shown slide
		private var currentSlideIndex:int;
		
		//Timer instance 
		private var timer:Timer;
		
		//Autoplay flag
		private var autoplay:Boolean;
		
		//showButtons flag
		private var showButtons:Boolean;
		
		//showSlideButtons flag
		private var showSlideButtons:Boolean;
		
		//Delay property
		private var delay:Number;
		
		//Array holding references to the slide buttons
		private var slideButtons:Array;
		
		//The previous selected slide button
		private var previousSelectedButton:MovieClip;
		
		//Color of the buttons
		private var buttonColor:uint = 0xE5E5E5;
		
		//Rollover color of the buttons
		private var buttonRolloverColor:uint = 0x00B6FF;
		
		
		public function ImageSlider() 
		{
			//Create a new loader to load the images
			imageLoader = new Loader();
			
			//Add listener for INIT event
			imageLoader.contentLoaderInfo.addEventListener(Event.INIT, imageLoaded);
			
			//Set initial alpha to 0
			alpha = 0;
			
			//Load XML
			loadXml();
			
			ColorShortcuts.init();
		}
		
		/**
		 * Timer TIMER eventhandler
		 */
		private function onTimer(e:TimerEvent):void 
		{
			//Show next slide
			showNextSlide();
		}
		
		/**
		 * nextButton CLICK eventhandler
		 */
		private function nextButtonClicked(e:MouseEvent):void 
		{
			resetTimer();
			
			//Show next slide
			showNextSlide();
		}
		
		/**
		 * prevButton CLICK eventhandler
		 */
		private function prevButtonClicked(e:MouseEvent):void 
		{
			resetTimer();
			
			//Show prev slide
			showPrevSlide();
		}
		
		/**
		 * Shows the next slide
		 */
		private function showNextSlide():void
		{
			//Increment currentSlideIndex by 1
			currentSlideIndex++;
			
			var time:Number = 0.3;
			
			//Check if we are showing the last slide, if so, show the first
			if (currentSlideIndex == images.length) {
				currentSlideIndex = 0;
				time = images.length * 0.3;
			}
			
			showSlide(currentSlideIndex, time);
		}
		
		/**
		 * Shows the previous slide
		 */
		private function showPrevSlide():void
		{
			//Decrement currentSlideIndex by 1
			currentSlideIndex--;
			
			var time:Number = 0.3;
			
			//Check if we are showing the first slide, if so, show the last
			if (currentSlideIndex < 0) {
				currentSlideIndex = images.length - 1;
				time = images.length * 0.3;
			}
			
			showSlide(currentSlideIndex, time);
		}
		
		/**
		 * Show slide with specific index
		 */
		private function showSlide(index:int, time:Number):void
		{
			
			if (showSlideButtons) {
				var button:MovieClip = slideButtons[index];
				selectButton(button);
			
				if (previousSelectedButton is MovieClip) deselectButton(previousSelectedButton);
				previousSelectedButton = button;
			}
			
			currentSlideIndex = index;
			
			//Start the tween
			Tweener.addTween(container, { x: slideWidth * currentSlideIndex * -1, time: time || 0.3, transition: "easeInOutSine" } );
		}
		
		/**
		 * Deselect specific button
		 */
		private function deselectButton(button:MovieClip):void
		{
			Tweener.addTween(button, { _color: buttonColor, time: 0.3 } );
			button.addEventListener(MouseEvent.MOUSE_OUT, buttonOut);
			button.mouseEnabled = true;
		}
		
		/**
		 * Select specific button
		 */
		private function selectButton(button:MovieClip):void
		{
			Tweener.addTween(button, {_color: buttonRolloverColor} );
			button.removeEventListener(MouseEvent.MOUSE_OUT, buttonOut);
			button.mouseEnabled = false;
		}
		
		/**
		 * Loads the XML file
		 */
		private function loadXml():void
		{
			//Create new loader
			var loader:URLLoader = new URLLoader(); 
			
			//Add COMPLETE listener
			loader.addEventListener(Event.COMPLETE, parseXml);
			
			//Load the "image.xml" file
			loader.load(new URLRequest("slider.xml")); 
		}
		
		/**
		 * Parse the XML file
		 */
		private function parseXml(e:Event):void 
		{
			//Get the image data from the XML file
			images = [];
			
			var xml:XML = new XML(e.target.data);
			var imageList:XMLList = xml.image;
			var i:int;
			var l:int = imageList.length();
			var imageData:ImageData;
			
			for (i = 0; i < l; i++) {
				imageData = new ImageData();
				imageData.source = imageList[i].@source;
				imageData.target = imageList[i].@target;
				images.push(imageData);
			}
			
			//Get the settings from the XML data
			slideWidth = xml.@width;
			slideHeight = xml.@height;
			autoplay = Boolean(Number(xml.@autoplay));
			delay = Number(xml.@delay);
			showButtons = Boolean(Number(xml.@showButtons));
			showSlideButtons = Boolean(Number(xml.@showSlideButtons));
			
			buttonColor = xml.@buttonColor;
			buttonRolloverColor = xml.@buttonRolloverColor;
			
			//Init the slideshow
			initSlideshow();
			
			//Init the slides
			initSlides();
			
			//Start loading the slides
			loadSlide();
			
			if (showSlideButtons) {
				var firstButton:MovieClip = slideButtons[0];
				selectButton(firstButton);
				previousSelectedButton = firstButton;
			}
		}
		
		
		/**
		 * Init the slideshow
		 */
		private function initSlideshow():void
		{
			//Add prevButton listener for CLICK, OVER and OUT events
			prevButton.addEventListener(MouseEvent.CLICK, prevButtonClicked);
			prevButton.addEventListener(MouseEvent.MOUSE_OVER, buttonOver);
			prevButton.addEventListener(MouseEvent.MOUSE_OUT, buttonOut);
			prevButton.buttonMode = true;
			
			//Add nextButton listener for CLICK event
			nextButton.addEventListener(MouseEvent.CLICK, nextButtonClicked);
			nextButton.addEventListener(MouseEvent.MOUSE_OVER, buttonOver);
			nextButton.addEventListener(MouseEvent.MOUSE_OUT, buttonOut);
			nextButton.buttonMode = true;
			
			//Add mousewheel listener
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			
			//Color the buttons
			var color:ColorTransform = new ColorTransform();
			color.color = buttonColor;
			prevButton.transform.colorTransform = color;
			nextButton.transform.colorTransform = color;
			
			//Set the mask size and position
			masks.slideMask.width = slideWidth;
			masks.slideMask.height = slideHeight;
			
			masks.slideMask.x = slideWidth / 2;
			masks.slideMask.y = slideHeight / 2;
		
			//Check whether to show the buttons
			if (showButtons) {
				//Position the buttons
				masks.prevButtonMask.y = prevButton.y = nextButton.y = masks.nextButtonMask.y = slideHeight / 2;
				masks.nextButtonMask.x = nextButton.x = slideWidth;
			}else {
				//Hide the buttons
				prevButton.visible = nextButton.visible = false;
				masks.prevButtonMask.x = masks.prevButtonMask.y = masks.nextButtonMask.x = masks.nextButtonMask.y = -100;
			}
			
			//Check if autoplay is set to "on"
			if (autoplay) {
				//Create new timer
				timer = new Timer(delay || 5000);
				
				//Add TIMER listener
				timer.addEventListener(TimerEvent.TIMER, onTimer);
				
				//Start timer
				timer.start();
			}
			
			if(showSlideButtons)initSlideButtons();
			
			Tweener.addTween(this, { alpha: 1, time: 0.5 } );
		}
		
		/**
		 * MOUSE_WHEEL eventhandler
		 */
		private function onMouseWheel(e:MouseEvent):void 
		{
			if (Tweener.isTweening(container))return;
			
			//Reset the timer
			resetTimer();
			
			//Show previous or next slide
			if (e.delta > 0) showNextSlide();
			else showPrevSlide();
		}
		
		/**
		 * Create the slide buttons
		 */
		private function initSlideButtons():void
		{
			var i:int;
			var l:int = images.length;
			var button:MovieClip;
			
			slideButtons = [];
			
			var color:ColorTransform = new ColorTransform();
			color.color = buttonColor;
		
			//Create, position, color and init the buttons
			for (i = 0; i < l; i++) 
			{
				//Create new button
				button = new slideButton();
				
				//Position the button
				button.x = i * 25;
				
				//Set the index property
				button.index = i;
				
				//Add listeners
				button.addEventListener(MouseEvent.CLICK, slideButtonClickHandler);
				button.addEventListener(MouseEvent.MOUSE_OVER, buttonOver);
				button.addEventListener(MouseEvent.MOUSE_OUT, buttonOut);
				
				//Set buttonMode to true
				button.buttonMode = true;
				
				//Color the button
				button.transform.colorTransform = color;
			
				//Add to displaylist
				buttonContainer.addChild(button);
				
				slideButtons.push(button);
			}
			
			
			//Position the buttons
			buttonContainer.x = (slideWidth - buttonContainer.width) / 2;
			buttonContainer.y = slideHeight + 15;
		}
		
		/**
		 * Eventhandler for slidebuttons CLICK event
		 */
		private function slideButtonClickHandler(e:MouseEvent):void 
		{
			var index:Number = e.target.index
			var time:Number = Math.abs(currentSlideIndex - e.target.index) * 0.3;
			
			resetTimer();
			showSlide(index, time);
		}
		
		
		/**
		 * Reset the timer
		 */
		private function resetTimer():void
		{
			if(timer is Timer){
				//Reset timer
				timer.reset();
				
				//Restart timer
				timer.start();
			}
		}
		
		/**
		 * Eventhandler for button mouse OVER events
		 */
		private function buttonOut(e:MouseEvent):void 
		{
			Tweener.addTween(e.target, {_color: buttonColor, time: 0.3 } );
		}
		
		
		/**
		 * Eventhandler for button mouse OUT events
		 */
		private function buttonOver(e:MouseEvent):void 
		{
			Tweener.addTween(e.target, {_color: buttonRolloverColor} );
		}
		
		/**
		 * Init the slides
		 */
		private function initSlides():void
		{
			//Attach the containers for the slides and position them
			var i:int;
			var l:int = images.length;
			var slide:MovieClip;
			slides = [];
			for (i = 0; i < l; i++) {
				slide = new slideContainer();
				slide.x = i * slideWidth;
				container.addChild(slide);
				slide.imageMask.width = slideWidth;
				slide.imageMask.height = slideHeight;
				slide.spinner.x = slideWidth / 2 - slide.spinner.width / 2;
				slide.spinner.y = slideHeight / 2 - slide.spinner.height / 2;
				slides.push(slide);
			}
		}
		
		/**
		 * Loads an image
		 */
		private function loadSlide():void
		{
			imageLoader.load(new URLRequest((images[loadCounter] as ImageData).source));
		}
		
		/**
		 * Eventhandler for imageLoader INIT event
		 */
		private function imageLoaded(event:Event):void
		{
			//Get the image
			var image:DisplayObject = event.target.content;
			
			//Get the slide
			var slide:MovieClip = slides[loadCounter];
			
			//Unload the loader
			imageLoader.unload();
			
			image.alpha = 0;
			
			//Add image to teh container
			slide.container.addChild(image);
			
			Tweener.addTween(image, {alpha: 1, time: 0.5 } );
			
			//Center the image
			slide.container.x = (image.width - slideWidth) / 2 * -1;
			slide.container.y = (image.height - slideHeight) / 2 * -1;
			
			//Check if a link target is set for the slide
			var imageData:ImageData = images[loadCounter];
			if (imageData.target.length > 0) {
				//Add CLICK listener
				slide.addEventListener(MouseEvent.CLICK, slideClicked);
				
				//Set mouseChildren to false
				slide.mouseChildren = false;
				
				//Set buttonMode to true
				slide.buttonMode = true;
				
				//Set the slides target
				slide.target = imageData.target;
			}
			
			//Load next slide if there is any
			if (loadCounter < images.length - 1) {
				loadCounter++;
				loadSlide();
			}
		}
		
		/**
		 * Eventhandler for slide CLICK event
		 */
		private function slideClicked(event:MouseEvent):void
		{
			//Navigates to the specified URL
			navigateToURL(new URLRequest(event.target.target));
		}
	}
}