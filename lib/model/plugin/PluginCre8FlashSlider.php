<?php

class PluginCre8FlashSlider extends BaseCre8FlashSlider
{
  public function __toString()
  {
    return $this->getName();
  }
  
  public function delete(PropelPDO $con = null)
  {
    $ret = parent::delete($con);
    Cre8FlashSliderXMLGenerator::updateAndSave();
    return $ret;
  }
  
  public function save(PropelPDO $con = null)
  {
    $ret = parent::save($con);
    Cre8FlashSliderXMLGenerator::updateAndSave();
    return $ret;
  }
  
}
