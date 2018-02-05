
<!---php
include($_SERVER['DOCUMENT_ROOT']."/_includes/common.php");
include_once($_SERVER['DOCUMENT_ROOT']."/_includes/geo.php");

$action = "";	if (isset($_REQUEST['action']))		$action = $_REQUEST['action'];
$storeid = 0;	if (isset($_REQUEST['storeid']))	$storeid = intval($_REQUEST['storeid']);
$debug = 0;		if (isset($_REQUEST['debug']))		$debug = 1;

$cookiedata = "0~0~~~0";
$cookieexpire = time()+60*60*24*30;

$data = array(
	'redirect' => '/',
	'store_id' => $storeid,
	'site_id' => $thissiteid,
	'site_name' => '',
	'site_host' => '',
	'store_address' => '',
	'store_city' => '',
	'store_province' => '',
	'changesite' => 0
);

if ($action == 'check') {
	
	/*
	$json = file_get_contents("http://api.easyjquery.com/ips/?ip=".$ip."&full=true");
	$json = json_decode($json, true);
	$lat = $json['cityLatitude'];
	$lon = $json['cityLongitude'];
	*/
	/*
	$json = file_get_contents("http://ip-api.com/json/".$ip);
	$json = json_decode($json, true);
	$lat = $json['lat'];
	$lon = $json['lon'];
	*/
	/*
	$json = file_get_contents("http://dazzlepod.com/ip/".$ip.".json");
	$json = json_decode($json, true);
	$lat = $json['latitude'];
	$lon = $json['longitude'];
	*/
	$json = file_get_contents("http://freegeoip.net/json/".$ip);
	$json = json_decode($json, true);
	$lat = $json['latitude'];
	$lon = $json['longitude'];

	if ($thissiteid==1) {
		//$neareststore = FindNearestStoreData($json['cityLatitude'], $json['cityLongitude'], 0);
		$d1 = FindNearestStoreData($lat, $lon, 1); // Find TBS
		$d2 = FindNearestStoreData($lat, $lon, 2); // Find RAS
		if ($d1['distance']<$d2['distance']) {
			$neareststore = $d1;
		} else {
			$neareststore = $d2;
		}
	} else {
		$neareststore = FindNearestStoreData($lat, $lon, $thissiteid);
	}

	if ($neareststore['status']==1) {
		$storeid = $neareststore['id'];
	} else {
		$data['message'] = "(".$neareststore['status'].") Nearest store not found";
	}
	
}

if ($storeid > 0) {

	$sql  = "SELECT s.*, si.name AS site_name, si.host AS site_host, sz.label AS store_zone_label";
	$sql .= " FROM stores AS s";
	$sql .= " LEFT JOIN sites AS si ON si.site_id = s.site_id";
	$sql .= " LEFT JOIN store_zones AS sz ON sz.store_zone_id = s.store_zone";
	$sql .= " WHERE s.store_id = ".mysql_real_escape_string($storeid)." ";
	$result = mysql_query($sql);

	if (mysql_errno()!=0) {
		echo "<p>Error 1:" . mysql_errno() . ": " . mysql_error() . "</p>\n";
		exit;
	}
	
	if (mysql_num_rows($result) > 0){
		$row = mysql_fetch_array($result);
		$cookiedata = $row['store_zone']."~".$row['store_id']."~".$row['store_city']."~".$row['store_address']."~".$row['site_id']."~".$row['store_zone_label'];
		$data['store_id'] = intval($row['store_id']);
		$data['site_id'] = intval($row['site_id']);
		$data['store_address'] = $row['store_address'];
		$data['store_city'] = $row['store_city'];
		$data['store_province'] = $row['store_province'];
		$data['site_name'] = $row['site_name'];
		$data['site_host'] = $row['site_host'];
	} else {
		$data['message'] = "Store not found";
	}
	
}

if ($thissiteid == $data['site_id'] || $data['site_id'] == 0) {
	setcookie('mystore', $cookiedata, $cookieexpire, '/');
}

/*
$data['cookie_after'] = $_COOKIE;
$data['cookie_data'] = $cookiedata;
$data['domains'] = $domains;
*/

//if ($myzone['site_id'] != 0 && $myzone['site_id'] != $data['site_id']) {
if ($action!="" || $storeid>0) {
	//if ($thissiteid != $data['site_id'] || $myzone['site_id'] != $data['site_id']) {
	if ($data['site_host'] != "" && $thissiteid != $data['site_id']) {
		$data['changesite'] = 1;
		$data['redirect'] = "http://".$data['site_host']."/setstore.php?action=redirect&storeid=".$data['store_id'];
	}
}

if ($action == 'redirect') {
	header("Location: /");
} else {
	header('Content-type: application/json');
	echo json_encode($data);
}
--->
