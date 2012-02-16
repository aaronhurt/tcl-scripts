<?

/*
	proLister 2.2

	Mini changelog:
	18.06.02: v1.0 - This script was created fast on one day...
	20.06.02: v1.1 - Fixed a little bug in line 214.
	21.06.02: v1.2 - Added show/ignore filetype filters..

	For more scripts.. go to http://php.holtsmark.no
	Rolf

	1.3 - changed images to winxp explorer icons - leprechau
	1.3 - added xss bug fixes - leprechau
	1.4 - added file size and date reporting - leprechau
	1.4 - removed $otherlocation option (doesn't work with filedate/size) - leprechau
	1.5 - added alot more images for various file types - leprechau
	1.6 - redid some icons and switched to a tabled format (looks alot nicer) - leprechau
	2.0 - complete redo using OOP and features added, also redid tables to have correct indenting :P - fiz
	2.1 - added PHPThrottle to have the option to throttle downloads - fiz
	2.2 - added ability to use any dir as prefix to enable out of webroot sharing :) also learned to spell except
		  also added text output of files with no extention AND fixed the weird blank in trail - fiz

*/



// config


// exept files (uses regexp so have fun :)
// please remember to delimit the regexp chars like . ? * ( ) & < > and more :P
$except[] = 'index\.php';
$except[] = 'error_log';
$except[] = 'access_log';
$except[] = 'style\.css';
$except[] = '\:2eDS_Store';
$except[] = 'Thumbs\.db';
$except[] = '^\..*?'; // this nifty regexp hides unix hidden files :)

$throttle = "yes"; //throttle the download? yes/no
$throttle_speed = "10"; // throttle speed in kilobits per secound

$prefix = ".";

// end config



if(empty($_GET["dir"])) $dir="/";
if(!empty($_GET["dir"])) $dir=$_GET["dir"];
if(preg_match('/\.\./', $_GET['dir'])) $dir = '/';

// check for ending /
if(substr($dir, strlen($dir), 1) != '/') $dir = $dir.'/';

$debug = false; // Display debug messages?
$ver="2.2";




// my debug helper :)
function print_rf($array) 
{
	echo '<pre>';
	print_r($array);
	echo '</pre>';
}


//$tmp_path = ini_get('session.save_path');
$tmp_path = '/tmp';

/**
 *	@desc A download Throttle Class Written in PHP *
**/
class PHPThrottle 
{
	/**
	 ** @desc outputs proper headers for file type
	 ** @param $file (string) file name
	 **
	 **/
	function headers($file)
	{
		//First, see if the file exists
		if (!is_file($file)) { die("<b>404 File not found![".$file."]</b>"); }
	
		//Gather relevent info about file
		$len = filesize($file);
		$filename = basename($file);
		$file_extension = strtolower(substr(strrchr($filename,"."),1));
	
		//This will set the Content-Type to the appropriate setting for the file
		switch( $file_extension ) {
			case "pdf": $ctype="application/pdf"; break;
			case "exe": $ctype="application/octet-stream"; break;
			case "zip": $ctype="application/zip"; break;
			case "doc": $ctype="application/msword"; break;
			case "xls": $ctype="application/vnd.ms-excel"; break;
			case "ppt": $ctype="application/vnd.ms-powerpoint"; break;
			case "gif": $ctype="image/gif"; break;
			case "png": $ctype="image/png"; break;
			case "jpeg":
			case "jpg": $ctype="image/jpg"; break;
			case "mp3": $ctype="audio/mpeg"; break;
			case "wav": $ctype="audio/x-wav"; break;
			case "mpeg":
			case "mpg":
			case "mpe": $ctype="video/mpeg"; break;
			case "mov": $ctype="video/quicktime"; break;
			case "avi": $ctype="video/x-msvideo"; break;
			case "html":
			case "htm": $ctype="text/html"; break;
			case "":
			case "txt": $ctype="text/plain"; break;
	
			//The following are for extensions that shouldn't be downloaded (sensitive stuff, like php files)
			case "php": die("<b>Cannot be used for ". $file_extension ." files!</b>"); break;
	
			default: $ctype="application/force-download";
		}
	
		//Begin writing headers
		header("Pragma: public");
		header("Expires: 0");
		header("Cache-Control: must-revalidate, post-check=0, pre-check=0");
		header("Cache-Control: public");
		header("Content-Description: File Transfer");
	  
		//Use the switch-generated Content-Type
		header("Content-Type: $ctype");
	
		if(!preg_match("/txt|htm/i", $file_extension) && $file_extension != "")
		{
			//Force the download
			$header="Content-Disposition: attachment; filename=".$filename.";";
			header($header );
			header("Content-Transfer-Encoding: binary");
			header("Content-Length: ".$len);
		}
	}	
	
	/**
	 ** @desc outputs fikle at proper speed, if $speed is 0 it will not throttle. 
	 **       $file is the file name to send, $speed is speed in kilobits per secound
	 **
	 ** @param $file string
	 ** @param $speed int
	 **
	 **/
	function get($file, $speed = 0) 
	{
		PHPThrottle::headers($file);
		if($speed > 0)
		{
			$fp = fopen($file, "r");
			while(!feof($fp))
			{
				echo fread($fp, (1024 * $speed));
				sleep(1);	
			}
	
		}
		if($speed == 0)
		{
			readfile($file);	
		}
	}
}

/**
 ** @desc Directory Listing Class
 **/
class Lister 
{
	/**
	 ** @desc this counts the amount of times a file has been downloaded
	 ** @param $name string
	 **/
	function countDownload($name) 
	{
		global $tmp_path;
		$tmp_file = $tmp_path.'/dirLister_downloads';
		$info = @unserialize(@join("", @file($tmp_file)));
		$info[$prefix.$name] = round($info[$prefix.$name]);
		$fp = fopen($tmp_file, 'w');
		$info[$prefix.$name]++;

		fputs($fp, serialize($info));
		fclose($fp);
	}
	/**
	 ** @desc this loads the download counts into an array
	 ** @param $name string
	 **/
	function getClick($name) 
	{
		global $tmp_path, $prefix;
		$tmp_file = $tmp_path.'/dirLister_downloads';
		$info = @unserialize(@join("", @file($tmp_file)));
		$info[$prefix.$name] = round($info[$prefix.$name]);
		if($info[$prefix.$name] == 0) { $info[$prefix.$name] = 'N/A'; }
		return $info[$prefix.$name];

	}
	/**
	 ** @desc this make the index.php act like a image and outputs the right image for the file type
	 ** @param $type string
	 **/
	function image($type) 
	{
	
		switch(strtolower($type)) 
		{

			case('dir'):
				$img =	 'R0lGODlhEAAOANUAAAAAAP///+339+z29tbf39Xe3sDIyElMTM7W1oeMjH6Dg2pubmltbf//'.
						   'mf/3kf/0jv/rhf/mgf/ge//Ub5lnAZpoApxqBJ5sBqBuCKNxC6VzDah2EKt5E658FrB+GLOB'.
						   'G7SBHLWCHbeEH7iFILqHIryJJL2KJb+MJ8CNKMKPKsWSLceUL8mWMcuYM8yZNNOgO9ypROaz'.
						   'Tu+8V/jFYP/MZ////wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAADUALAAA'.
						   'AAAQAA4AAAaZwFrN1WKtCAOhcukKOAMpQ3IpbDaujYCJJAp9PARBreV4mM1PZydRqLEgEZV8'.
						   'jiqNQJ8PYSVRpf8RARkJKhMuWIhXMw0YCyk0LQ0Ok5STMg0XDCg0Kg0Qn6CfMQ0WDCY0Jw0S'.
						   'q6yrMA0VDCQ0Iw0Tt7i3Lw0UCwReHh0cGxoZGBcWFRQHCjUGCgzR0tMMCgZCBAja29wIBDVB'.
						   'ADs=';
				 break;
			case('exe'):
			case('bat'):
			case('com'):
				$img =	 'R0lGODlhEAAOAKIAAAAAAP///wAAv8DAwICAgP///wAAAAAAACH5BAEAAAUALAAAAAAQAA4A'.
						'AAMwSLrcOjDKSAAZIuud6+VCAIiiNzioNQRs67LmKwfx7NY2rOYtnvs2DyoFKBqPSEACADs=';
				break;

			case('html'):
			case('htm'):
				$img =	 'R0lGODlhEAAQAPcAAAAAAP///1JSg1ZWh1VWhlhZiVtci2prm2FjkGhql29ynnR4o32Bq3p+'.
						'p2NtnHSAsr3K/77K/3GBsrrK/8rY/8nX/sjW/bfM/8HQ9snY/8bV/MbV+7TM/7PF7KW54bDN'.
						'/6K33oSj1q3N/5+02Cg9W4ir3oep3KvN/6nO/yJEajJdjyZEZrvO4+z1/ypsrD94sUBkiXWo'.
						'3nSUtKHE5rrb+7/f/7TS8Mzl/9Pp/9vt//P5//3+/yp7xDBzskKV5EmKxEd4pSlFX5S31qjG'.
						'48Ti/9vq+OTy/+Hs9uz2/x5gmjGV7TOY7DuY6kOq/kuBrkhsiUtsiKa2w+jw9zOc7DKP2DWR'.
						'2TKIzT+p91Gm5XGjyH6mxJivwSmW5Umm5kuItFWVwHSz3yac5S+i61mWvKnV8KC9zyOR0iif'.
						'5iaKwh9xnjGq8j2g2n3O+73X5nvQ+4K10H+ux7bY6TO08DOp3UvB+W7E623B5pjC1Tu57z+6'.
						'7j3L/svq9uLz+O35/JTp/Gvz//X//+v19dTd3b3FxY+Vlf///wAAAAAAAAAAAAAAAAAAAAAA'.
						'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'.
						'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'.
						'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'.
						'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'.
						'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'.
						'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'.
						'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAIUALAAAAAAQABAAAAjmAAsJNEGwYIkQ'.
						'DwQFEsjQxI4AECM+yDJoYUOIUtq8eRNHQgQfFRuOGTkyQB4HBw4wICTwzhg/f/Tg+RLAzhEd'.
						'ERqwdLlnDho0Z8Q4CYCkBYQFhPiMAQQnzYwAPJpUkVHEyAQFhJbCkWOmCxYqS5oAYZHjQgJC'.
						'TOmEScK2LQwWODggIFTGjRouSWbc2Lt3yI0PBgh5WfNiipIeM6wofmKDiIgBgrdEccFkyZU6'.
						'dYIIoVHjhABCbLQA+qEixQoSUEZgqEABxec+ZMDEsOABRAcNGzJQaE2ApcACwIMLB+5bIKHj'.
						'yJMfDwgAOw==';
				break;

			case('url'):
				$img =	'R0lGODlhEAAQAPcAAAAAAIAAAACAAICAAAAAgIAAgACAgICAgMDcwKbK8Co/qio//ypfACpf'.
						'VSpfqipf/yp/ACp/VSp/qip//yqfACqfVSqfqiqf/yq/ACq/VSq/qiq//yrfACrfVSrfqirf'.
						'/yr/ACr/VSr/qir//1UAAFUAVVUAqlUA/1UfAFUfVVUfqlUf/1U/AFU/VVU/qlU//1VfAFVf'.
						'VVVfqlVf/1V/AFV/VVV/qlV//1WfAFWfVVWfqlWf/1W/AFW/VVW/qlW//1XfAFXfVVXfqlXf'.
						'/1X/AFX/VVX/qlX//38AAH8AVX8Aqn8A/38fAH8fVX8fqn8f/38/AH8/VX8/qn8//39fAH9f'.
						'VX9fqn9f/39/AH9/VX9/qn9//3+fAH+fVX+fqn+f/3+/AH+/VX+/qn+//3/fAH/fVX/fqn/f'.
						'/3//AH//VX//qn///6oAAKoAVaoAqqoA/6ofAKofVaofqqof/6o/AKo/Vao/qqo//6pfAKpf'.
						'Vapfqqpf/6p/AKp/Vap/qqp//6qfAKqfVaqfqqqf/6q/AKq/Vaq/qqq//6rfAKrfVarfqqrf'.
						'/6r/AKr/Var/qqr//9QAANQAVdQAqtQA/9QfANQfVdQfqtQf/9Q/ANQ/VdQ/qtQ//9RfANRf'.
						'VdRfqtRf/9R/ANR/VdR/qtR//9SfANSfVdSfqtSf/9S/ANS/VdS/qtS//9TfANTfVdTfqtTf'.
						'/9T/ANT/VdT/qtT///8AVf8Aqv8fAP8fVf8fqv8f//8/AP8/Vf8/qv8///9fAP9fVf9fqv9f'.
						'//9/AP9/Vf9/qv9///+fAP+fVf+fqv+f//+/AP+/Vf+/qv+////fAP/fVf/fqv/f////Vf//'.
						'qszM///M/zP//2b//5n//8z//wB/AAB/VQB/qgB//wCfAACfVQCfqgCf/wC/AAC/VQC/qgC/'.
						'/wDfAADfVQDfqgDf/wD/VQD/qioAACoAVSoAqioA/yofACofVSofqiof/yo/ACo/Vf/78KCg'.
						'pICAgP8AAAD/AP//AAAA//8A/wD//////ywAAAAAEAAQAAAI0gDtCfzi5QtBg160IBBo79/A'.
						'fxAj/tPixVA0hv+8QHyFYIyYRVoO7TAk0OEXHShR/vshQ0vLAwIT6Fh07ccGGysFHtJyz14C'.
						'G68uSJBw4QLOWf+oaTnwSsc/MRIS/JPwY4KXV68SyLjn1MsGCTt2TLiww0aCWUoPZPxxwYEB'.
						't25lIHh1SMaBu3gPAMCKNUHWrWolAhgqQYbfQzHuQgQA4B+AMWPqfVy0yMU9tQD0Oq5nlhpW'.
						'xIobL05ArbRnrZclOpYRg7UM13oZy8584PLl2gcCAgA7';
				break;

			case('ini'):
				$img =	 'R0lGODlhDwAQAPcAAAAAAP///5SFh1tIS0U5QaGWpbi0znRto4OCmHJyeZSUmpKSlrKytM/Q'.
						'6rW31bK107G00l9gabi91NDU5M/W7EpPWpKXopGXo6ClrkZSZV5oeHN2e11peurs709cbVJf'.
						'cF9re2Nvf3mBjJGZpHJ4gHN+jLG/0H+JlZadpoCEiW97iIOOmoiSnY6Yo5umseHt+aautvr8'.
						'/peirKOttuDt+erz+4q96ZjI7bLV8bXY8t3t+d7t+cTIy7fb87bZ8r/e9Km0vMLIzPn8/rnd'.
						'9M3n99rt+b3FyrPb873h9czn997w+uTw97jBxuv1++Ho7Lnh9dbt+d3w+uLw98bQ1dPb3/v9'.
						'/szV2d7n69ni5tjw+t/w98PP1Nnj583s+N3w98ft+dnz+9rw98Tt+c/w+tjw99rk58Xw+sfw'.
						'+tPy+tLw99Tw9+Do6n+DhM/y+s3w99Dw9+Ls7srw997l5t3k5fT9/u329/L8/e/5+uv19t38'.
						'/ur9/tX//9n//93//+L//+X//+b//+r//+v//+z//+7//+////D///L///P///T///X///H7'.
						'++r09Pb///X+/tnh4cDHx+319fn//+v19O729dzk4/j9+q6yruTp1N3fudDPnNHNj8XAgL6z'.
						'V7auWcS7ZsG2YLWXKmlnYMi9mtGeCtmmG9WtQKiJNLicTMyza/Ls28SOCdmlHdunKOi1OOm2'.
						'OreYR8+rVGdeR8qRDsucLuSwPu67RfK+T/XCUs6lRfDFY/HHZbimfvnjsOHNoMaLDqqBMPK+'.
						'UPvQdaF4KuGoQWJYRdjJra6Va93QuqptFZtvLPz696ZuIe7o4KFgD9e9oZpYGYt5apVOFqdt'.
						'QFc+K1pBPKqqqv///wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'.
						'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'.
						'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAANcALAAAAAAPABAAAAj/AK9pwsQpU6dN'.
						'oD55usaQ4YRopwSEOnCsAC9UCJjAsXPNAYVUDYwZUIVsWTMMLbDcufZgiRIdNF7ECBCgA4kT'.
						'VhjRgSDlUKMmNar08pVCVK5RjyhB0JIFSpEdQojpsiarFKxLlSB4GVQokSVhuHZZKzaLlClI'.
						'EMIg6fEjSrJbtmIB+7VqGBsIZG7Y8IHjWbBarlqxolVtAwQ1T44MSTLF2bRXzKApq7AAQpo2'.
						'Y7rkIGJChzRqBAYk4AHhzZkvaMDoMaRIkoUIChjMgeDGjJg8fwIR8olCRBA5kSDE2cOnjx9A'.
						'ggohusCCSh1HEpxMWmMExggVGjKAmHFl0TUuLjh4DfgQosQKGUC2lMHDMCAAOw==';
				break;

			case('mrc'):
				$img =	'R0lGODlhDwAQALMAAAAAAP///wAAgP//AICAAP8AAIAAAICAgP///wAAAAAAAAAAAAAAAAAA'.
						'AAAAAAAAACH5BAEAAAgALAAAAAAPABAAAARUEJ1J60T4iM27OJknghKnbecXfgEXnCTcbi+6'.
						'HrNQq0bv/4AgyFAoEosFw2BAACCOSWSSSWj+jr4lYQCAYrXVoNe45DqfSKwS3E0bg2XrtYcI'.
						'2hERADs=';
				break;

			case('pdf'):
				$img =	 'R0lGODlhEAAQAMQAAAAAAP///+cxNOg8Puc+QelHSOdLTelTVeZWWehZW+ZcXuRkZuVsbuN9'.
						'fuSEheKMjeGbnOGsreC0teK3uN/Ky97j4/8AAOcvL+ZFReNzcuG8vN7U1N3d3REREf///wAA'.
						'ACH5BAEAAB4ALAAAAAAQABAAAAVjoCcCZFl2nagCXOu2nZWaNMnFMmDtPM+eul6P5erUaK/U'.
						'6GWIvG6rFwHyVHqIrUvGVYEuWxDKg5GMcjaJiEQwwCAmVqID82hIIo9FIc5RYJ5nGnEMBhSA'.
						'HBVxB4dFKiiPkJAhADs=';
				break;

				
			case('network'):
				$img =	 'R0lGODlhEAAPAPcAAAAAAP///5iYt2RkdIGBk8zM3jAwNERESW5udDw8P3h4fXBwdUNDRoqK'.
						'j+rq7nx8fZmZmnV2iXN0g4GCjk1OV0xOVYOFjEVITIGIj0hMUF5jaDk8P05SVnuAhRscHbS5'.
						'vpufo77CxrK1uHBydNPU1cfIyc/b5t3p9Nvn8tDb5bvFzuDx/93q9cvX4crW4MjU3rbByrXA'.
						'ybS/yHh/hdPf6c7a5MHM1Wxyd3J4fcfP1sPK0NLY3d/x/5WhqqWvt5Oco9rn8dfk7qiyukpO'.
						'UcvV3ba/xm10eWRqbmNpbTI1N5mcnsbJy7W4uktQU4WHiIyNjf/3ze/lu+/r2tmtFurAKevB'.
						'LN+4K/Lkr/Xu1NWtM9KwSdi2TtKnJsafLNixQcimRa9/Br6QFr2PGql3AqNyAqJwAqh2A/z8'.
						'/Pf39/Ly8uzs7Obm5uHh4d/f397e3tjY2NPT09HR0dDQ0MnJycfHx8PDw7m5ubi4uLW1ta6u'.
						'rqWlpaSkpKOjo5ycnJmZmZiYmI6OjoKCgoGBgYCAgH19fXl5eXFxcWxsbGJiYlBQUE5OTjQ0'.
						'NCcnJxUVFf///wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'.
						'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'.
						'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'.
						'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'.
						'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'.
						'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'.
						'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAI4ALAAAAAAQAA8AAAjgAB0JTJEjBIk1'.
						'S3SoOCFQIJEdTAodupPmjJo2aEp8KALEkQg4buiwaVPxIhoHBRpYcKGkDx6Ra+S8iVMHggIG'.
						'BCQYAZHnT6A9duIAkigI0SIBETTQ6OBkDp9BgR4oMkQIwYAKGW44qiEEx4gnehYkOEDhQpMj'.
						'P2wIRGEiBoZEEwx4GDJDyIsgDQWyoBGoR6MkPkygyJuXixctXb7IIOynceMtUgJgCeO4cQs/'.
						'PHisWJElCpQrYjJnZsSBkWnTU6pYoQLmtOkNLZBwmD2GDBkzZTbM3u2ohe8WMGTPRgIjb0AA'.
						'Ow==';
					break;

			case('png'):
			case('gif'):
			case('jpg'):
			case('jpeg'):
			case('bmp'):
			case('psd'):
				$img =	 'R0lGODlhDgAQAPcAAAAAAP///9PH1NbM2WBElEdHrP7+//Pz9IuOuJWZxJOWwaqz9Zacxpee'.
						'yYuRtpmhzMzV/298rn6JtJek0nOCtZqo1pim03aIu52t2brJ9HqPwr3N832VyKvB8K/D8LHF'.
						'8bXI8rfJ8rrM86W97qi/74Gczz1tvYSj1oOi1Yir3oep3FhkdVdjdF1oec3h/yRw1cDb/8Td'.
						'/8ng/+ns8KjP/67S/2J1jbLU/7bW/7vZ/216inqHl5zG9WNwf2JvfomUoNHb5tvi6pnL/KfT'.
						'/6nU/63W/6zV/q7W/6/V/bLY/7PY/bPX/Ljb/7fZ/Lnc/r3e/73d/dPp/9ns/5Keqt/v/+Tp'.
						'7u7w8kOW5X278sLh/8jk/87n/9br/9zu/97v/6Swu+Lx/+Ty/+r1/9Xf6AyL8USm91Or9obG'.
						'/rrFzvD4/9/m7LO9xfb7/wGZ/wmU8orO/8Pm/665wa24wLC7w/r9/wOb+bvGzYfP+ePx+c/Z'.
						'3w+n4tfj5+Pu8VjwUGz5Nt3jxr/DgeXUCdzJJOfGJ+fGKOnIKe7XZPrNAvDMKv80Afk0Be81'.
						'D8Z7e/r6+vj4+Pb29v///wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'.
						'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'.
						'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'.
						'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'.
						'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'.
						'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'.
						'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAJAALAAAAAAOABAAAAjgAFUIHJjihAo8'.
						'kBJCUhGgYQADdNiowGLjy56FDiGySVOmzJUdaPioaPQwYhoxECAskDAljwpHiWIyguMFTBcu'.
						'GXTYUfEopiITbdq8ieJiQ4s5Kg7EJPAiaBsnMkSwkKPCSqJFBZoGPRMjxFQUMwQMIONGT1Ah'.
						'MEBMLVElDJU7ffzUMaMkx4epHNRQkWLoUCBBPJjg8DBVQxApfxANIlQI0JEbHaZeGBNlC5Qm'.
						'S5AYIVKDxFQKQLZoyfKESZIiQ2iMWBEnAoYKFiY8aMAggQIHCHqsgfTDxwoWwIOv8PEDUkAA'.
						'Ow==';
				break;

			case('reg'):
				$img =	'R0lGODlhEAAQAKIAAAAAAP///wD//wCAgMDAwICAgP///wAAACH5BAEAAAYALAAAAAAQABAA'.
						'AANMaFrcrtCUQCslJUprScjQxFFACYQO053SMASCC6ySEACvvBb2gMuzCgEwiZlwwQtRlkPu'.
						'ej2nkAh7GZPK43E0DI1oC4J4TO4qtOhSAgA7';
				break;

			case('txt'):
				$img =	'R0lGODlhDAAPAOYAAAAAAP///760urm203h4wXh4wMTG4sjN57zDzr/K2MHO2b/N1bzM1MHP'.
						'1r/O1b7N1LbKzrvN0L7Q0ZukpH2EhGpwcNni4tjh4dfg4NXe3tTd3dLb28DIyKatraGoqJOZ'.
						'mYySknF2durz8+jx8efw8ODp6d/o6MrS0rO6urC3t56kpH+EhGhsbLzBwY+Tk7u9vX5/f/z9'.
						'/ez19MPKyfH49+n08uz29Ov186Gmpff7+tS/S6OGPrycT5BrMYZpQp2CXamQb7yqkZN+Y415'.
						'b4RubXFxcf///wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'.
						'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'.
						'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'.
						'AAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAEYALAAAAAAMAA8AAAeDgEY8Oj07OkI6RD8aRgcE'.
						'BD1BQwNAAj8eJgUGPjU+Nj45PgFFGQURNag2NDkxoxoFDag1qqyuBQ41MLovtUWvC7K0rb4F'.
						'Erm6MC8Btg/Bq8OvCce7y8QKzr2vDLkvwrYQqDcyMy04Lh8WIwgTFBUsISsgKhwkRhgpHSgc'.
						'JxsXJSJGAgEAOw==';
				break;

			case('w3m'):
				$img =	'R0lGODlhEAAPAOYAAAAAAP///xcTDUQ5KUg9LWlWPYZuTq2QZ3plSUM4Ka6SbLGUbqSJZpx8'.
						'VaiGXayMY6KDXlVFMkc6KlJDMcajdzIpHqyNaG9bQ7WVblJEMnplTKmManZiSl5OO7mada6R'.
						'bopzV1tMOqqObYZwVsiogYtwUamJZKiIZE9AL25aQ62OasGed6+QbJp+X0E1KMSgebaWcWlW'.
						'QY92WWJRPsKhfLucedGuiG1bR+G8k9Syi82shqeLbYx1XNa1j8+wjFhLPNu6lqWDYl1LOUg6'.
						'LLSSb7iXdJ2BZL+efMmnhNy4ktWyjsuqhyojHOnEnQcGBcWgffrTrv///wAAAAAAAAAAAAAA'.
						'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'.
						'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'.
						'AAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAFEALAAAAAAQAA8AAAejgFEAg4SFUYeHAB0sJg4e'.
						'MDAbPxoAiIITTRgHNSEunioaTogATBUInS4cIZ2UowA4Qakcqp1NlaNQD7K0Lju3iTcLqKqe'.
						'PL+CSCsXKiHEJ0PHADIoNkYfnhwMNtEjLU8kMC4ZFDNK0RIrCk8pqi86ItEDKEcEJSAxBhoR'.
						'FwK/AAkFSPhosqSHkiQ5lAC5BWCCkCI0TJhoIAKGBSIQ/BXaOChKIAA7';
				break;

			case('wma'):
			case('mp3'):
			case('mp4'):
			case('m3u'):
				$img =	'R0lGODlhEAAQAPcAAAAAAP///7KaqvDr+O/r9lJSg1ZWh1xcjGNjaVVWhlhZiVtci2prm19h'.
						'kGFjkGhql2ZolCcwkG9ynnR4oycwjn2Bq3p+p3F3mnSAsr3K/77K/zhOoRY6tB9GxLrK/8rY'.
						'/9fa41FttLfM/7TM/xFNxrDN/x1gy4uv7YSj1q3N/zJx04ir3oep3KvN/8HM3I+16KnO//P4'.
						'/5K98IWr25C46id935XC9a/N7cjU4uz1/wV68I7G/7/f/8zl/9Pp/9vt/9bc4vP5//n8//3+'.
						'/0KV5KbV/6TJ7MTi/8nl/+Ty/2q7/3fA/oq33bDa/+v2/1+1+WS6/mW6/mi8/nGjyPj8/5e5'.
						'z3GZsdnf4ev19dTd3b3FxY+Vlfb//8nR0YSJiW1xcW5ycvj//5CSkn5/f/D499jf3qW+qGZ7'.
						'YT1YIJS7Y3PAAbjPk9PhvWShAVySAX69DluDFKraWn2tJVF4AVp3HXCPMv/96WloYJSHM4x7'.
						'K4t6K8iiB8ahCcenGuvEIenDJOrGL+rINuvQYOvSZPfmofLLOdbV0nRtXfbz7d2yiDY1NPTr'.
						'5/xJF/+TdvSvm/OvnPxSJ/lULPdYL/99W/+AX/Wlkvaql/Wbif9GIu6ckJ6ennFxcW5ubiYm'.
						'JhwcHAEBAf///wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'.
						'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'.
						'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'.
						'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'.
						'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'.
						'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAKAALAAAAAAQABAAAAj6AEEJZEGw4AoU'.
						'GLJgEcjQxpAAECNimKJlIUMZQzJqHMJAA5GKDF8MEUJFCEkhDFJW0CIwDI1MmdKYMYIkSIwg'.
						'Gix4ARWmUiRMmNS0qVOliJMcGSZ84WIJEqVLieK8cUOHSZMkHiR8WSRpkiMxQAawkTPnzJIf'.
						'Ih58ecSoESJOmzQRWAMHjRIfIxx8EVDjydtOnxAQ+NNHSo8SC77M0OFXkacxIOwU6gPlSAoD'.
						'X1yYqHFDk6EAdgb9wROFR4sCX8iEIKHiBA5CggLtsbLjAwzUoK5s4NChAyA/fA5BaHBAQYIv'.
						'AstciEAhj547YL5Il76FIZYsXbJr354lIAA7';
				break;

			case('zip'):
			case('tgz'):
			case('gz'):
			case('rar'):
				$img =	 'R0lGODlhEAAQAOYAAAAAAP///28aII0GUY0CU5ICWoYCU+hatfRjwP9syv950P990v+H1/+V'.
						'3v+j5f++8ODg8ISHl5OXpJicqKGmsb7H09DY4NTc5O/2/fX6/wBYpwA4bgBXogBWnwBWnCWd'.
						'/zmm/0it/1u1/2O5/3PA/4XI/5vS//D4//L5/wBUlgBUlABQhQA8ZwA4XgAyULDk/wDckgCK'.
						'WhbfmyzipULlrlnouF7punLrwozvzbv14QCIWACHVwGDUxlOABVDABE2ADJQALm5AICAAHNz'.
						'AFBQAMXFHv//sVgdAFAAADIyMv///wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'.
						'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'.
						'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'.
						'AAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAEoALAAAAAAQABAAAAebgEeCg4SFShQTEhECQwaO'.
						'j49IFRYWEANGDw4NDAsKCQgHSBYnAQECRQWpqqkESBkoGBdJQki1trcAubq7vIeJES0rLMPE'.
						'xC6TlStGLyYlJCMiISAfLqOlG0UaGhwdHR4pKSour7GzxecuvOq7voo+RD3x8vI/yBBERjk4'.
						'NzY1NDMyYPywFgBIkBg6EircweMHOVlC5kn8sa6ikkAAOw==';
				break;

			case('php'):
			case('phps'):
				$img =	 'R0lGODlhEAAQAPcAAAAAAIAAAACAAICAAAAAgIAAgACAgICAgMDAwP8AAAD/AP//AAAA//8A'.
						'/wD/////////////////////////////////////////////////////////////////////'.
						'////////////////////////////////////////////////////////////////////////'.
						'////////////////////////////////////////////////////////////////////////'.
						'////////////////////////////////////////////////////////////////////////'.
						'////////////////////////////////////////////////////////////////////////'.
						'////////////////////////////////////////////////////////////////////////'.
						'////////////////////////////////////////////////////////////////////////'.
						'////////////////////////////////////////////////////////////////////////'.
						'////////////////////////////////////////////////////////////////////////'.
						'////////////////////////////////////////////////////////////////////////'.
						'////////////////////////////////////////////////////////////////////////'.
						'////////////////////////////////////////////////////////////////////////'.
						'////////////////////////////////////////////////////////////////////////'.
						'/////////////////////////////////ywAAAAAEAAQAAAIaQAfCBxI8MGBgggPIBi4EGFD'.
						'hA4PGGC48GHBigIRWITI4OADjRAzfsQYUiQCByAJHmCAoKMBhRotHphJk2ZMjywHzEQwk0DH'.
						'igtnAiAAgCcBAzxPMphoEGbHnis3CqyJ4GXJqQavahUYEAA7';
				break;
				
			case('torrent'):
				$img =	 'R0lGODlhDgAQAPcAAAAAAIAAAACAAICAAAAAgIAAgACAgICAgMDcwKbK8Co/qio//ypfACpf'.
						'VSpfqipf/yp/ACp/VSp/qip//yqfACqfVSqfqiqf/yq/ACq/VSq/qiq//yrfACrfVSrfqirf'.
						'/yr/ACr/VSr/qir//1UAAFUAVVUAqlUA/1UfAFUfVVUfqlUf/1U/AFU/VVU/qlU//1VfAFVf'.
						'VVVfqlVf/1V/AFV/VVV/qlV//1WfAFWfVVWfqlWf/1W/AFW/VVW/qlW//1XfAFXfVVXfqlXf'.
						'/1X/AFX/VVX/qlX//38AAH8AVX8Aqn8A/38fAH8fVX8fqn8f/38/AH8/VX8/qn8//39fAH9f'.
						'VX9fqn9f/39/AH9/VX9/qn9//3+fAH+fVX+fqn+f/3+/AH+/VX+/qn+//3/fAH/fVX/fqn/f'.
						'/3//AH//VX//qn///6oAAKoAVaoAqqoA/6ofAKofVaofqqof/6o/AKo/Vao/qqo//6pfAKpf'.
						'Vapfqqpf/6p/AKp/Vap/qqp//6qfAKqfVaqfqqqf/6q/AKq/Vaq/qqq//6rfAKrfVarfqqrf'.
						'/6r/AKr/Var/qqr//9QAANQAVdQAqtQA/9QfANQfVdQfqtQf/9Q/ANQ/VdQ/qtQ//9RfANRf'.
						'VdRfqtRf/9R/ANR/VdR/qtR//9SfANSfVdSfqtSf/9S/ANS/VdS/qtS//9TfANTfVdTfqtTf'.
						'/9T/ANT/VdT/qtT///8AVf8Aqv8fAP8fVf8fqv8f//8/AP8/Vf8/qv8///9fAP9fVf9fqv9f'.
						'//9/AP9/Vf9/qv9///+fAP+fVf+fqv+f//+/AP+/Vf+/qv+////fAP/fVf/fqv/f////Vf//'.
						'qszM///M/zP//2b//5n//8z//wB/AAB/VQB/qgB//wCfAACfVQCfqgCf/wC/AAC/VQC/qgC/'.
						'/wDfAADfVQDfqgDf/wD/VQD/qioAACoAVSoAqioA/yofACofVSofqiof/yo/ACo/Vf/78KCg'.
						'pICAgP8AAAD/AP//AAAA//8A/wD//////ywAAAAADgAQAAAIjwAPIEBgb2BBgjH+2bNX5Z/D'.
						'hw9VHQBg74A9iBAJToxxEePDAzHqWfyHQBUCQyVPxhDUguM/lKYQCEIQU2CLkQBQAkCwU5DF'.
						'lhd3qgIw1GQVeyKDqkqws+eBV0D/AZhqaOhAi0n/mTSJUpAqjlGrJogZ0xBWiz4PVDnAlq0g'.
						'qC49PkQ6Uq5Dey1Tmkypt15AADs=';
				break;
	
			default:
				$img = 'R0lGODlhDgAQAMQAAAAAAP///wAA/wAAmQD//wCAAP//AOfn1v/MM/8AAIAAAMzMzMvLy5mZ'.
					   'mYaGhlVVVQgICP///wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'.
					   'ACH5BAEAABEALAAAAAAOABAAAAVWoCOOZBOdzqGua/OgQSzLTfA6c+4+D07+EEYv4BggBsgk'.
					   'xOZLOgfLIS4XOER9AYMiJqheiQFFIiAgCKxMcDhWKKClLNYXQq/b09Rcb8Hv+/k8gYKDDyEA'.
					   'Ow==';
				break;

		}
		return $img;
	}
	
	/**
	 ** @desc this prints out a user freindly trail to make for easy navigation
	 ** @param $sep string
	 **/
	function printTrail($sep) 
	{
		global $dir;
		$dirs = explode('/', $dir);

		// quickclean
		foreach($dirs as $g) { if($g != '') { $df[] = $g; } }
		
		$tList[] = '<a href="index.php">Home</a>';

		for($i = 0; $i < (count($df) - 1); $i++) 
		{

			$cur = $df[$i] != '.' ? $df[$i] : 'Home';
			$sList[] = $df[$i];

			if($cur != '') 
			{
				$tList[] = '<a href="index.php?dir=/'.join("/", $sList).'/">'.$cur.'</a>';
			}
				
		}
		$cur = $df[(count($df) - 1)] != '.' ? $df[(count($df) - 1)] : 'Home';
		$tList[] = $cur;
		
		echo '<img src="index.php?image=network"/> '.join(' '.$sep.' ', $tList);
		
	}
	
	
	/**
	 ** @desc this prints a custom header
	 **/
	function printHeader() 
	{
		global $dir;
		echo '
<!doctype html public "-//w3c//dtd html 4.0 transitional//en">
<html>
	<head>
		<meta name="Author" content="Fiz">
		<meta HTTP-EQUIV="pragma" CONTENT="no-cache">
		<title>downloads and things</title>
		<link rel="stylesheet" type="text/css" href="style.css">
	</head>
	<body style="font: 12px verdana;">'."\n\n";
	
	}
	
	/**
	 ** @desc this prints a custom footer
	 **/
	function printFooter() 
	{
		global $dir;
		echo '
	</body>
</html>';

	}
	
	/**
	 ** @desc this get the size of a file
	 ** @param $filename string
	 ** @return $hfilesize - proper file size
	 **/
	function getfsize($filename) 
	{
		global $prefix;
	
		$file_size = filesize($prefix.$filename);

		if ($file_size >= 1099511627776) {
			$hfilesize = number_format(($file_size / 1099511627776),2) . " TB";
		}
		elseif ($file_size >= 1073741824) {
			$hfilesize = number_format(($file_size / 1073741824),2) . " GB";
		}
		elseif ($file_size >= 1048576) {
			$hfilesize = number_format(($file_size / 1048576),2) . " MB";
		}
		elseif ($file_size >= 1024) {
			$hfilesize = number_format(($file_size / 1024),2) . " KB";
		}
		elseif ($file_size >= 0) {
			$hfilesize = $file_size . " bytes";
		}
		else {
			$hfilesize = "0 bytes";
		}
		return $hfilesize;
	}
	
	
	/**
	 ** @desc this gets an array of directories and files
	 ** @param $dir string
	 ** @return $list - list of directories and files
	 **/
	function listdir($dir) 
	{

		global $except, $prefix;

		// time to gather and sort the files and dirs
		$files = dir($prefix.$dir) or die('Error reading/opening' .htmlentities(stripslashes($dir)));
		while ($current = $files->read()) {

			// *nix hidden dir/file check
			$check = explode(".", $current);
			if($check[0] != '' && !preg_match('/'.join("|", $except).'/i', $current)) {
				if(is_dir($prefix.$dir.$current) && $current != '.' && $current != '..') {
					$list['dirs'][strtolower($current)] = $dir.$current;
				}
				if(!is_dir($prefix.$dir.$current)) {
					$list['files'][strtolower($current)] = $dir.$current;
				}
			}
		}
		if(is_array($list['files'])) { ksort($list['files'], SORT_STRING); reset($list['files']); }
		if(is_array($list['dirs'])) { ksort($list['dirs'], SORT_STRING); reset($list['dirs']); }

		// return neatly sorted list :)
		return $list;
	}

}
// Class end



// this is where everything gets outputted put headers here


// precheck for image output
if($_GET['image'] != '') 
{
	$img = base64_decode(Lister::image($_GET['image']));
	
	header("Content-type: image/gif");
	header("Content-length: ".strlen($img));

	echo $img;

	die();
}

// precheck #2 for download
if($_GET['download'] != '') 
{
	Lister::countDownload($prefix.stripslashes($_GET['download']));
	$file = stripslashes($prefix.$_GET['download']);
	if($throttle == 'yes') { PHPThrottle::get($file, $throttle_speed); }
	else { PHPThrottle::get($file, 0); }
	die();

}

$list = Lister::listdir($dir);

Lister::printHeader();


Lister::printTrail('>');
echo '<hr />';


echo '
		<table style="width: 100%; font: 12px verdana;">
			<tr>
				<th align="left" style="width: 16px;">&nbsp;</th>
				<th align="left">Filename</th>
				<th align="center">Modified</th>
				<th align="center">Size</th>
				<th align="center">Clicks</th>
			</tr>
';

// printing dirs 1st
if(is_array($list['dirs']))
{
	foreach($list['dirs'] as $d)
	{
		$d = str_replace("//", "/", $d);
		$truename = explode("/", $d);
		$true = $truename[(count($truename) - 1)];
		echo '
			<tr onmouseover="style.background=\'#eeeeee\'" onmouseout="style.background=\'#ffffff\'">
				<td align="left" style="width: 16px;"><img src="index.php?image=dir"/></td>
				<td align="left"><a href="index.php?dir='.$d.'/">'.$true.'</a></td>
				<td align="center">'.date("m/d/y", filemtime($prefix.$d)).'</td>
				<td align="center">'.Lister::getfsize($d).'</td>
				<td align="center">'.Lister::getClick($d).'</td>
			</tr>';

	}
}

// printing files 1st
if(is_array($list['files']))
{
	foreach($list['files'] as $f)
	{
		$f = str_replace("//", "/", $f);
		$truename = explode("/", $f);
		$true = $truename[(count($truename) - 1)];
		$ext = explode('.', $true);
		$ext = $ext[(count($ext) - 1)];
		
		echo '
			<tr onmouseover="style.background=\'#eeeeee\';" onmouseout="style.background=\'#ffffff\'">
				<td style="width: 16px;"><img src="index.php?image='.$ext.'"/></td>
				<td><a href="index.php?download='.$f.'">'.$true.'</a></td>
				<td align="center">'.date("m/d/y", filemtime($prefix.$f)).'</td>
				<td align="center">'.Lister::getfsize($f).'</td>
				<td align="center">'.(Lister::getClick($f) == 'N/A' ? 0 : Lister::getClick($f)).'</td>
			</tr>';

	}
}

echo '</table>';

Lister::printFooter();



?>
