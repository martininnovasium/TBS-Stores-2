<!---php
$isadmin = 0;
include($_SERVER['DOCUMENT_ROOT']."/_includes/common.php");

$testonly = false;
$error = "";
$message = "";

$daysToExpire = 30;

//$example_coupon_id = ecode('189587|1', 1);
//echo 'encoded: ' . $example_coupon_id . '/n';
//exit;

//for testing
//$customer_id = 189587;
//$site_id = 1;

$coupon_id = 0;		if (isset($_REQUEST['coupon_id'])) $coupon_id = $_REQUEST['coupon_id'];
$contest_id = 0;	if (isset($_REQUEST['contest_id'])) $contest_id = intval($_REQUEST['contest_id']);
$debug = 0;			if (isset($_REQUEST['debug'])) $debug = $_REQUEST['debug'];

if ($debug) {
	echo "<pre>\n";
	echo "coupon_id=[".$coupon_id."] contest_id=[".$contest_id."] today=[".$today."](".date("M j, Y", $today).")\n";
}

$customer_id = 0;
$timestamp = 0;

if (substr($coupon_id,0,4)=="test") {
	if ($debug) echo "in:test\n";
	$tmp = substr($coupon_id,4,99);
	$customer_id = intval($tmp);
} elseif (substr($coupon_id,0,2)=="mc") {
	if ($debug) echo "in:mc\n";
	$fromMC = true;
	$tmp = substr($coupon_id,2,99);
	$tmp = str_replace(",","",$tmp);
	$customer_id = intval($tmp);
} else {
	if ($debug) echo "in:other\n";
	$tmp = dcode($coupon_id,2);
	$parameters = explode('|', $tmp);
	if ($debug) print_r($parameters);
	$customer_id = intval($parameters[0]);
	$site_id = intval($parameters[1]);
	if (count($parameters)>2) {
		$timestamp = preg_replace("/[^\d]/","",$parameters[2]);
		if ($timestamp!=$parameters[2]) $timestamp = 0;
	}
}

if ($debug) {
	echo "customer_id=[".$customer_id."] site_id=[".$site_id."] timestamp=[".$timestamp."](".date("M j, Y", $timestamp).")\n";
}

if ($customer_id > 0) {

	$sql = "SELECT r.*, s.store_city, s.store_province FROM registration AS r LEFT JOIN stores AS s on s.store_id = r.customer_store_id WHERE r.customer_id = " . $customer_id . "";
	$result = mysql_query($sql); //echo $sql;
	if (mysql_errno()!=0) {
		echo "<p>Error 1:" . mysql_errno() . ": " . mysql_error() . "</p>\n";
		echo "<!-- [".$sql."] -->\n";
		exit;
	}
	if (mysql_num_rows($result) == 0){
		echo "No member information was found.";
		exit;
	}
	$row = mysql_fetch_assoc($result);
	
	if ($debug) {
		echo "customer_date_confirmed=[".$row['customer_date_confirmed']."] customer_date_registered=[".$row['customer_date_registered']."] customer_date_modified=[".$row['customer_date_modified'].")\n";
	}
	
	if ($row['customer_date_confirmed']!="" && $row['customer_date_confirmed']!="0000-00-00 00:00:00") {
		$userDate =	strtotime($row['customer_date_confirmed']);
	} else {
		if ($row['customer_date_registered']!="" && $row['customer_date_registered']!="0000-00-00 00:00:00") {
			$userDate =	strtotime($row['customer_date_registered']);
		} else {
			if ($row['customer_date_modified']!="" && $row['customer_date_modified']!="0000-00-00 00:00:00") {
				$userDate =	strtotime($row['customer_date_modified']);
			} else {
				$userDate =	date();
			}
		}
	}

	/*
	if ($contest_id!=0) {
		// get contest enter date

		if ($debug) echo "get contest entry date\n";

		$sql = "SELECT date_registered FROM contest_registration WHERE contest_id = ".$contest_id." AND customer_id = ".$customer_id."";
		$result = mysql_query($sql); //echo $sql;
		if (mysql_errno()!=0) {
			echo "<p>Error 2:" . mysql_errno() . ": " . mysql_error() . "</p>\n";
			echo "<!-- [".$sql."] -->\n";
			exit;
		}
		if (mysql_num_rows($result)){
			$row = mysql_fetch_assoc($result);
			$userDate =	strtotime($row['date_registered']);
			if ($debug) echo "found contest entry date\n";
		}

	} else {

		if ($debug) echo "auto get contest entry date\n";

		$sql = "SELECT contest_id, date_registered FROM contest_registration WHERE customer_id = ".$customer_id." ORDER BY date_registered DESC";
		$result = mysql_query($sql); //echo $sql;
		if (mysql_errno()!=0) {
			echo "<p>Error 2:" . mysql_errno() . ": " . mysql_error() . "</p>\n";
			echo "<!-- [".$sql."] -->\n";
			exit;
		}
		if (mysql_num_rows($result)){
			$row = mysql_fetch_assoc($result);
			$userDate =	strtotime($row['date_registered']);
			$contest_id = $row['contest_id'];
			if ($debug) echo "found contest entry date [".$row['contest_id']."]\n";
		}

	}
	*/
	if ($debug) echo "userDate=[".$userDate."](".date("F j, Y", $userDate).")\n";

	if ($timestamp==0) {
		$timestamp = $userDate;
	}

	if ($debug) echo "daysToExpire=[".$daysToExpire."]\n";

	// Build expire date
	$m = date('m', $timestamp); //month
	$d = date('d', $timestamp); 
	$y = date('y', $timestamp);
	$new_date = strtotime('+'.$daysToExpire.' day', mktime(0, 0, 0, $m, $d, $y));

	if ($debug) echo "new_date=[".$new_date."](".date("F j, Y", $new_date).")\n";
 
	//if ($contest_id!=0 && isbetween($giftContestStart, $giftContestEnd)) {
	/*
	if ($contest_id!=0) {
		// For contest period
	*/
		$textX = 153.5;
		$textY = 116.75;
		$tempate_pdf = $_SERVER['DOCUMENT_ROOT'].'/pdf/Welcome_Coupon_5off25.pdf';
	/*
	} else {

		$textX = 150;
		$textY = 75;
		if ($site_id==1) {
			$tempate_pdf = $_SERVER['DOCUMENT_ROOT'].'/pdf/TBS10off_template.pdf';
		} elseif($site_id==2) {
			$tempate_pdf = $_SERVER['DOCUMENT_ROOT'].'/pdf/RAS10off_template.pdf';
		} else {
			$tempate_pdf = $_SERVER['DOCUMENT_ROOT'].'/pdf/TBS10off_template.pdf';
		}

	}
	*/
	
	if ($debug) {
		echo "[".$tempate_pdf."][".$textX."][".$textY."][".Date("Y-m-d",$today)."]";
	}
	
	require_once($_SERVER['DOCUMENT_ROOT'].'/_includes/pdf/fpdf.php');
	require_once($_SERVER['DOCUMENT_ROOT'].'/_includes/pdf/fpdi.php');

	// initiate FPDI
	$pdf =& new FPDI();
	// add a page
	$pdf->AddPage();
	// set the sourcefile
	$pdf->setSourceFile($tempate_pdf);
	// import page 1
	$tplIdx = $pdf->importPage(1);
	// use the imported page and place it at point 10,10 with a width of 100 mm
	$pdf->useTemplate($tplIdx, 0, 0, 210);

	// now write some text above the imported page
	$pdf->SetFont('Arial');
	$pdf->SetFontSize('10');
	$pdf->SetTextColor(155,0,0);
	$pdf->SetXY($textX, $textY);

	$pdf->SetXY($textX, $textY + 5);
	$pdf->Write(10, date("M j, Y", $new_date));

	if ($debug) {
		echo "render completed";
		exit;
	}

	$pdf->Output();

	//logging?
	//logAction("SendCoupon: Could not open file. [" . $new_pdf . "]");
	//echo " sendCoupon Error: Could not open file. [$new_pdf]";
	//return 0;

} else {
	echo "There was no coupon information specified.";
	exit;
}

/* ---------------------------- */

function ecode($s,$l) {
  for($i=0;$i<$l;$i=$i+4) $s=strrev(base64_encode($s)); return $s;
}

function dcode($s,$l) {
  for($i=0;$i<$l;$i=$i+4) $s=base64_decode(strrev($s)); return $s;
}


--->