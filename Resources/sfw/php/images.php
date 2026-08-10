<?php

function setImageStates ($path,$dstFolder){
//States: Standard, Hover, Click and Disabled

// Initial settings
	chdir($dstFolder);
	$filename=basename($path);
	$im1 = imagecreatefrompng($path);
	imagealphablending($im1, false);
	
	$sizes=getimagesize($path);
	$width=$sizes[0];
	$height=$sizes[1];
	
// Creation of destination image
	$imDst = imagecreatetruecolor($width,4*$height);
	imagealphablending($imDst, false); // do not blend previous images
	imagesavealpha($imDst, true); // use transparencies

// Original image
	imagecopy($imDst,$im1,0,0,0,0,$width,$height);

// Click: add more bright
	imagefilter($im1, IMG_FILTER_BRIGHTNESS, 20);
	imagecopy($imDst,$im1,0,$height,0,0,$width,$height);

//Hover: add more bright to previous image
	imagefilter($im1, IMG_FILTER_BRIGHTNESS, 35);
	imagecopy($imDst,$im1,0,2*$height,0,0,$width,$height);

//Disabled: reduce brightness and set grayscale
	imagefilter($im1, IMG_FILTER_BRIGHTNESS, -30);
	imagefilter($im1, IMG_FILTER_GRAYSCALE);
	imagecopy($imDst,$im1,0,3*$height,0,0,$width,$height);
	
//Write image to file
	imagepng($imDst,$filename);

//Clear memory
	imagedestroy($imDst);
	imagedestroy($im1);
	return $filename;
}

?>