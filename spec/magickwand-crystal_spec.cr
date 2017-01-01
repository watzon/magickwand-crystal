require "./spec_helper"

describe Magickwand do
  test_img1 = "spec/test1.png" # PNG: 640x480 - zip comp
  test_img2 = "spec/test2.jpg" # PNG
  tmp_img1 = "spec/tmp.jpg" # JPG
  wand = nil

  Spec.before_each do
    LibMagick.magickWandGenesis
    wand = LibMagick.newMagickWand
  end

  Spec.after_each do
    LibMagick.destroyMagickWand wand
    LibMagick.magickWandTerminus
  end

  it "should be ready" do
    LibMagick.isMagickWand( wand ).should be_true
    # LibMagick.isMagickWandInstantiated.should be_true # NOTE: Travis says: "undefined IsMagickWandInstantiated" - check Magick version
  end

  it "should read an image and get basic info" do
    LibMagick.magickReadImage( wand, test_img1 ).should be_true
    String.new( LibMagick.magickGetImageFormat( wand ) ).should eq "PNG"
    # ( LibMagick.magickGetImageWidth(  wand ) > 0 ).should be_true
    LibMagick.magickGetImageWidth(  wand ).should eq 640
    LibMagick.magickGetImageHeight( wand ).should eq 480
    LibMagick.magickGetImageCompression( wand ).should eq LibMagick::CompressionType::ZipCompression
    LibMagick.magickGetImageChannelStatistics( wand ).value.class.should eq LibMagick::ChannelStatistics
  end

  it "should scale an image" do
    File.delete tmp_img1 rescue nil
    LibMagick.magickReadImage wand, test_img1
    w = LibMagick.magickGetImageWidth wand
    h = LibMagick.magickGetImageHeight wand
    LibMagick.magickScaleImage wand, w / 2, h / 2
    LibMagick.magickWriteImage( wand, tmp_img1 ).should be_true
    # Read the new image
    wand2 = LibMagick.newMagickWand
    LibMagick.magickReadImage( wand2, tmp_img1 ).should be_true
    String.new( LibMagick.magickGetImageFormat( wand2 ) ).should eq "JPEG"
    LibMagick.magickGetImageWidth(  wand2 ).should eq 320
    LibMagick.magickGetImageHeight( wand2 ).should eq 240
    LibMagick.destroyMagickWand wand2
  end

  it "should resize an image" do
    File.delete tmp_img1 rescue nil
    LibMagick.magickReadImage wand, test_img2
    w = LibMagick.magickGetImageWidth wand
    h = LibMagick.magickGetImageHeight wand
    LibMagick.magickResizeImage wand, w / 2, h / 2, LibMagick::FilterTypes::LanczosFilter, 1
    LibMagick.magickWriteImage( wand, tmp_img1 ).should be_true
    # Read the new image
    wand2 = LibMagick.newMagickWand
    LibMagick.magickReadImage( wand2, tmp_img1 ).should be_true
    String.new( LibMagick.magickGetImageFormat( wand2 ) ).should eq "JPEG"
    LibMagick.destroyMagickWand wand2
  end
end
