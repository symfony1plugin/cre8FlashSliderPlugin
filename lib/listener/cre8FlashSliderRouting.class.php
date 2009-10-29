<?php

class cre8FlashSliderRouting
{
  static public function listenToRoutingLoadConfigurationEvent(sfEvent $event)
  {
    $r = $event->getSubject();
    $r->prependRoute('get_cre8_flash_slider', new sfRoute('/get_cre8_flash_slider', array('module' => 'cre8FlashSlider', 'action' => 'index')));
  }
  
  static public function addRouteForAdmin(sfEvent $event)
  {
    $r = $event->getSubject();
    $r->prependRoute('cre8_flash_slider', new sfPropelRouteCollection(array(
      'name'                 => 'cre8_flash_slider',
      'model'                => 'Cre8FlashSlider',
      'module'               => 'cre8FlashSliderAdmin',
      'prefix_path'			 => 'cre8FlashSliderAdmin',
      'with_wildcard_routes' => true,
      'requirements'         => array(),
    )));
   
  }
  
}