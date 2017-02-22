<?php
if(isset($_REQUEST['line']) && $_REQUEST['line'] != '') {
	$url = 'http://cloud.tfl.gov.uk/TrackerNet/PredictionSummary/' . $_REQUEST['line'];
	echo (file_get_contents($url));
}

// if(isset($_REQUEST['url']) && $_REQUEST['url']!="") {
	// $url = $_REQUEST['url'];
	// if (preg_match('/\b(https?|ftp):\/\/*/', $url) !== 1) die;
	// echo (file_get_contents($url));
// }
?>