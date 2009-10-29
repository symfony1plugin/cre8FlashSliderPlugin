<?php

/**
 * Cre8FlashSlider form.
 *
 * @package    ##PROJECT_NAME##
 * @subpackage form
 * @author     ##AUTHOR_NAME##
 * @version    SVN: $Id: sfPropelFormTemplate.php 10377 2008-07-21 07:10:32Z dwhittle $
 */
class PluginCre8FlashSliderForm extends BaseCre8FlashSliderForm
{
  public function configure()
  {
    $this->setWidget('filename', new sfWidgetFormInputFileEditable(array(
      'label' => 'Slide Image',
      'file_src' => '/uploads/' . $this->getObject()->getFilename(),
      'is_image' => true,
      'edit_mode' => !$this->isNew(),
      'with_delete' => false,
      'template' => '<div>%file%<br />%input%<br />%delete% %delete_label%</div>'
    )));
    $this->setValidator('filename', new sfValidatorFile(array(
      'required' => $this->isNew(),
      'path' => sfConfig::get('sf_upload_dir'),
      'mime_types' => 'web_images'
    )));
    
    $this->widgetSchema->setHelp('filename', sfConfig::get('app_cre8_flash_slider_width', 468) . 'px width by ' . sfConfig::get('app_cre8_flash_slider_height', 268) . 'px height');
  }
}
