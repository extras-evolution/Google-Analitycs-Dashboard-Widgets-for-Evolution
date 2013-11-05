//<?php
/**
 * Google Analitycs Dashboard Widget
 *
 * show Visitors and Pagevisits
 *
 * @category    plugin
 * @version     0.1
 * @license     http://www.gnu.org/copyleft/gpl.html GNU Public License (GPL)
 * @package     modx
 * @author      Dmi3yy (dmi3yy@gmail.com)
 * @internal    @events OnManagerWelcomePrerender
 * @internal    @modx_category Manager and Admin
 * @internal    @properties &ga_email = GA Email;text; ga_profile@mail.com &ga_password = GA Password;text; ga_password &ga_profile_id = GA profile_id;text;XXXXXX &ga_days = GA Days Show;text;30 &ga_height = GA Widget Height;text;250
 * @internal    @installset base
 * @internal    @disabled 1
 */

/* Where found GA profile_id:
The other answers are based on using the OLD VERSION analytics page and are correct that the ID=xxxxxxxx is the profile ID 
https://www.google.com/analytics/reporting/?reset=1&id=XXXXXXXX&pdr=20110702-20110801 
For the NEW VERSION analytic page it is the number at the end of the ERL starting with p 
https://www.google.com/analytics/web/#home/a11345062w43527078pXXXXXXXX/
*/
$e = &$modx->Event;
if($e->name == 'OnManagerWelcomePrerender'){	
	if(!file_exists(MODX_BASE_PATH . 'assets/cache/gadw.widgetCache-'.date(z).'.php')){
		
		require (MODX_BASE_PATH.'assets/plugins/gadw/class_gapi.php');
		
		$ga = new gapi($ga_email,$ga_password);
		$ga->requestReportData($ga_profile_id,array('Date'),array('visitors','pageviews'),array('Date'),null,date("Y-m-d", mktime(0,0,0,date("m"),date("d")-$ga_days,date("Y"))),date("Y-m-d"));	
		
		$visits = array();
		$views= array();
		foreach($ga->getResults() as $result2){
			$visits[] = array(strtotime($result2).'000',$result2->getVisitors(), $result2->getPageviews());
		}
		
		if(count($visits)) {
			foreach($visits as $key=>$visit) { 
				$flot_datas_visits[] = '['.$visit[0].','.$visit[1].']';
				$flot_datas_views[] = '['.$visit[0].','.$visit[2].']';
			}
			$flot_data_visits = '['.implode(',',$flot_datas_visits).']';
			$flot_data_views = '['.implode(',',$flot_datas_views).']';
		}
		
		$output = ' <div class="sectionHeader">Google Analytics</div>
					<div class="sectionBody" id="gadw" style="height:'.$ga_height.'px"></div>
					<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>
					<script language="javascript" type="text/javascript" src="../assets/plugins/gadw/jquery.flot.min-time.js"></script>
					<script type="text/javascript">
						$(document).ready(function() {
							var visits = '.$flot_data_visits.'; 
							var views = '.$flot_data_views.';
							$.plot($("#gadw"),[{ label: "Visits", data: visits },
											   { label: "Pageviews", data: views }],
								{xaxis: {mode: "time",minTickSize: [1, "day"]},lines: { show: true },points: { show: true },grid: { backgroundColor: "#fffaff" }
							});
						});
					</script>';
		
		foreach (glob(MODX_BASE_PATH . 'assets/cache/gadw.widgetCache-*.php') as $filename) {
   			unlink($filename);
		}
		file_put_contents(MODX_BASE_PATH . 'assets/cache/gadw.widgetCache-'.date(z).'.php', $output);		
	}else{
		$output = file_get_contents( MODX_BASE_PATH . 'assets/cache/gadw.widgetCache-'.date(z).'.php');
	}
	$e->output($output);
}