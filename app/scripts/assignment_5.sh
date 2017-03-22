5#!/bin/bash
#######################################################################################
# FLATWOKEN ICON THEME CONFIGURATION SCRIPT
# Copyright: (C) 2014 FlatWoken icons
# Author:  Alessandro Roncone
# email:   alecive87@gmail.com
# Permission is granted to copy, distribute, and/or modify this program
# under the terms of the GNU General Public License, version 2 or any
# later version published by the Free Software Foundation.
#  *
# A copy of the license can be found at
# http://www.robotcub.org/icub/license/gpl.txt
#  *
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
# Public License for more details
#######################################################################################


#######################################################################################
# HELP
#######################################################################################
usage() {
cat << EOF
***************************************************************************************
DEA SCRIPTING
Author:  Alessandro Roncone   <alessandro.roncone@iit.it>

This script scripts through the commands available for the DeA Kids videos.

USAGE:
        $0 options

***************************************************************************************
OPTIONS:

***************************************************************************************
EXAMPLE USAGE:

***************************************************************************************
EOF
}

#######################################################################################
# HELPER FUNCTIONS
#######################################################################################
gaze() {
    echo "$1" | yarp write ... /gaze
}

speak() {
    echo "\"$1\"" | yarp write ... /iSpeak
}

blink() {
    echo "blink" | yarp rpc /iCubBlinker/rpc
    sleep 0.5
}
#
# breathers() {
#     # echo "$1"  | yarp rpc /iCubBlinker/rpc
#     # echo "$1" | yarp rpc /iCubBreatherH/rpc:i
#     echo "$1" | yarp rpc /iCubBreatherRA/rpc:i
#     sleep 0.4
#     echo "$1" | yarp rpc /iCubBreatherLA/rpc:i
# }
#
# breathersL() {
#    echo "$1" | yarp rpc /iCubBreatherLA/rpc:i
# }
#
# breathersR() {
#    echo "$1" | yarp rpc /iCubBreatherRA/rpc:i
# }
#
# stop_breathers() {
#     breathers "stop"
# }
#
# start_breathers() {
#     breathers "start"
# }

go_home_helperL() {
    # This is with the arms over the table
    echo "ctpq time $1 off 0 pos (-12.0 24.0 23.0 64.0 -7.0 -5.0 10.0    12.0 -6.0 37.0 2.0 0.0 3.0 2.0 1.0 0.0)" | yarp rpc /ctpservice/left_arm/rpc
    # This is with the arms close to the legs
    # echo "ctpq time $1 off 0 pos (-6.0 23.0 25.0 29.0 -24.0 -3.0 -3.0 19.0 29.0 8.0 30.0 32.0 42.0 50.0 50.0 114.0)" | yarp rpc /ctpservice/left_arm/rpc
}

go_home_helperR() {
    # This is with the arms over the table
    echo "ctpq time $1 off 0 pos (-15.0 23.0 22.0 48.0 13.0 -10.0 8.0 0.0 35.0 20.0 2.0 0.4 1.0 0.0 8.0 6.0)" | yarp rpc /ctpservice/right_arm/rpc
    # This is with the arms close to the legs
    # echo "ctpq time $1 off 0 pos (-6.0 23.0 25.0 29.0 -24.0 -3.0 -3.0 19.0 29.0 8.0 30.0 32.0 42.0 50.0 50.0 114.0)" | yarp rpc /ctpservice/right_arm/rpc
}

go_home_helper() {
    go_home_helperR $1
    go_home_helperL $1
}

go_home() {
    sleep 1.0
    go_home_helper 2.0
    sleep 3.0
}

greet_with_right_thumb_up() {
    echo "ctpq time 1.5 off 0 pos (-44.0 36.0 54.0 91.0 -45.0 0.0 12.0      21.0 0.0 0.0 0.0 59.0 140.0 80.0 125.0 210.0)" | yarp rpc /ctpservice/right_arm/rpc
    sleep 1.5 && smile && sleep 1.5
    go_home
}

greet_with_left_thumb_up() {
    echo "ctpq time 1.5 off 0 pos (-44.0 36.0 54.0 91.0 -45.0 0.0 12.0      21.0 0.0 0.0 0.0 59.0 140.0 80.0 125.0 210.0)" | yarp rpc /ctpservice/left_arm/rpc
    sleep 1.5 && smile && sleep 1.5
    go_home
}

skeptic() {
  echo "set leb sur" | yarp rpc /icub/face/emotions/in
  echo "set reb evi" | yarp rpc /icub/face/emotions/in
  echo "set mou hap" | yarp rpc /icub/face/emotions/in
}

thinking() {
  echo "set leb sur" | yarp rpc /icub/face/emotions/in
  echo "set reb evi" | yarp rpc /icub/face/emotions/in
  echo "set mou sur" | yarp rpc /icub/face/emotions/in
}

smile() {
    echo "set all hap" | yarp rpc /icub/face/emotions/in
}

surprised() {
    echo "set mou sur" | yarp rpc /icub/face/emotions/in
    echo "set leb sur" | yarp rpc /icub/face/emotions/in
    echo "set reb sur" | yarp rpc /icub/face/emotions/in
}

sad() {
    echo "set mou sad" | yarp rpc /icub/face/emotions/in
    echo "set leb sad" | yarp rpc /icub/face/emotions/in
    echo "set reb sad" | yarp rpc /icub/face/emotions/in
}

cun() {
    echo "set reb cun" | yarp rpc /icub/face/emotions/in
    echo "set leb cun" | yarp rpc /icub/face/emotions/in
}

angry() {
    echo "set all ang" | yarp rpc /icub/face/emotions/in
}

evil() {
    echo "set all evi" | yarp rpc /icub/face/emotions/in
}
urbi_et_orbi () {
  echo "ctpq time 2.0 off 0 pos (-76.087912 18.0 41.54022 79.989011 -3.194914 -12.263736 5.846154 27.349497 26.770445 25.996681 25.79368 0.4 22.865714 16.888222 8.569178 147.786317)" | yarp rpc /ctpservice/right_arm/rpc
  echo "ctpq time 2.0 off 0 pos (-44.967033 28.285714 60.441319 89.307692 -11.570818 -38.021978 -15.516484 27.065163 26.882944 26.516972 25.43044 -0.4 21.312919 18.725107 8.94287 146.865506)" | yarp rpc /ctpservice/right_arm/rpc
  echo "ctpq time 2.0 off 0 pos (-59.56044 16.065934 57.716044 76.120879 -4.65387 -15.252747 -12.615385 27.349497 27.332938 24.956098 26.15692 -0.4 22.089317 16.520845 8.569178 147.325912)" | yarp rpc /ctpservice/right_arm/rpc
  echo "ctpq time 2.0 off 0 pos (-36.967033 52.197802 26.507253 99.769231 -18.671728 -33.098901 -20.263736 27.349497 27.332938 22.354641 25.43044 0.8 21.701118 17.990353 8.94287 147.325912)" | yarp rpc /ctpservice/right_arm/rpc
  sleep 3.0
  go_home_helper 2.0
}
wait_till_quiet() {
    sleep 0.3
    isSpeaking=$(echo "stat" | yarp rpc /iSpeak/rpc)
    while [ "$isSpeaking" == "Response: speaking" ]; do
        isSpeaking=$(echo "stat" | yarp rpc /iSpeak/rpc)
        sleep 0.1
        # echo $isSpeaking
    done
    echo "I'm not speaking any more :)"
    echo $isSpeaking
}
right_two() {
  echo "ctpq time 1.0 off 7 pos (-31.252747 17.56044 10.595165 93.263736 34.300664 -27.472527 -20.791209 32.183162 29.357913 6.7459 115.513985 -0.8 -1.590807 -0.011117 2.963797 207.638987)" | yarp rpc /ctpservice/right_arm/rpc
  sleep 3.0
  go_home_helperR 2.0
}
victory() {
    echo "ctpq time 1.0 off 7 pos                                       (18.0 40.0 50.0 167.0 0.0 0.0 0.0 0.0 222.0)" | yarp rpc /ctpservice/$1/rpc
    echo "ctpq time 2.0 off 0 pos (-57.0 32.0 -1.0 88.0 56.0 -30.0 -11.0 18.0 40.0 50.0 167.0 0.0 0.0 0.0 0.0 222.0)" | yarp rpc /ctpservice/$1/rpc
}

victory_both() {

    echo "ctpq time 1.0 off 7 pos                                       (18.0 40.0 50.0 167.0 0.0 0.0 0.0 0.0 222.0)" | yarp rpc /ctpservice/left_arm/rpc
    echo "ctpq time 2.0 off 0 pos (-57.0 32.0 -1.0 88.0 56.0 -30.0 -11.0 18.0 40.0 50.0 167.0 0.0 0.0 0.0 0.0 222.0)" | yarp rpc /ctpservice/left_arm/rpc

    echo "ctpq time 1.0 off 7 pos                                       (18.0 40.0 50.0 167.0 0.0 0.0 0.0 0.0 222.0)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time 2.0 off 0 pos (-57.0 32.0 -1.0 88.0 56.0 -30.0 -11.0 18.0 40.0 50.0 167.0 0.0 0.0 0.0 0.0 222.0)" | yarp rpc /ctpservice/right_arm/rpc

    sleep 3.0
    go_home
}

point_eye() {
    echo "ctpq time 2 off 0 pos (-50.0 33.0 45.0 95.0 -58.0 24.0 -11.0 10.0 28.0 11.0 78.0 32.0 15.0 60.0 130.0 170.0)" | yarp rpc /ctpservice/left_arm/rpc
    sleep 3.0 && blink && blink
    go_home
}

point_ear_right() {
    echo "ctpq time 2 off 0 pos (-18.0 59.0 -30.0 105.0 -22.0 28.0 -6.0 6.0 55.0 30.0 33.0 4.0 9.0 58.0 113.0 192.0)" | yarp rpc /ctpservice/right_arm/rpc
    sleep 3.0
    go_home_helperR 2.0
}

point_ears() {

    echo "ctpq time 1 off 0 pos (-10.0 8.0 -37.0 7.0 -21.0 1.0)" | yarp rpc /ctpservice/head/rpc
    echo "ctpq time 2 off 0 pos (-18.0 59.0 -30.0 105.0 -22.0 28.0 -6.0 6.0 55.0 30.0 33.0 4.0 9.0 58.0 113.0 192.0)" | yarp rpc /ctpservice/left_arm/rpc
    sleep 2.0

    echo "ctpq time 2 off 0 pos (-10.0 -8.0 37.0 7.0 -21.0 1.0)" | yarp rpc /ctpservice/head/rpc
    echo "ctpq time 2 off 0 pos (-18.0 59.0 -30.0 105.0 -22.0 28.0 -6.0 6.0 55.0 30.0 33.0 4.0 9.0 58.0 113.0 192.0)" | yarp rpc /ctpservice/right_arm/rpc

    echo "ctpq time 2 off 0 pos (-0.0 0.0 -0.0 0.0 -0.0 0.0)" | yarp rpc /ctpservice/head/rpc
    go_home_helperL 2.0
    go_home_helperR 2.0

}

point_arms() {

    echo "ctpq time 2 off 0 pos (-60.0 32.0 80.0 85.0 -13.0 -3.0 -8.0 15.0 37.0 47.0 52.0 9.0 1.0 42.0 106.0 250.0)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time 2 off 0 pos (-64.0 43.0 6.0 52.0 -28.0 -0.0 -7.0 15.0 30.0 7.0 0.0 4.0 0.0 2.0 8.0 43.0)" | yarp rpc /ctpservice/left_arm/rpc
    sleep 3.0
    go_home_helperL 2.0
    go_home_helperR 2.0

}

fonzie() {
    echo "ctpq time 2.0 off 0 pos ( -3.0 57.0   3.0 106.0 -9.0 -8.0 -10.0 22.0 0.0 0.0 20.0 62.0 146.0 90.0 130.0 250.0)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time 2.0 off 0 pos ( -3.0 57.0   3.0 106.0 -9.0 -8.0 -10.0 22.0 0.0 0.0 20.0 62.0 146.0 90.0 130.0 250.0)" | yarp rpc /ctpservice/left_arm/rpc
    sleep 1.0
    smile
    go_home_helper 2.0
}

hello_left() {
    echo "ctpq time 1.5 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0 -11.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/left_arm/rpc
    sleep 2.0
    echo "ctpq time 0.5 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0  25.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/left_arm/rpc
    echo "ctpq time 0.5 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0 -11.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/left_arm/rpc
    echo "ctpq time 0.5 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0  25.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/left_arm/rpc
    echo "ctpq time 0.5 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0 -11.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/left_arm/rpc
    smile
    go_home 2.0
    smile
}

hello_left_simple() {
    echo "ctpq time 1.5 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0 -11.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/left_arm/rpc
    smile
    sleep 2.0
    go_home_helperL 2.0
    smile
}

hello_right_simple() {
    echo "ctpq time 1.5 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0 -11.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/right_arm/rpc
    smile
    sleep 2.0
    go_home_helperR 2.0
    smile
}

interaction_right() {
    echo "ctpq time 1.5 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0 -11.0 0.0 55.0 30.0 33.0 4.0 9.0 58.0 113.0 192.0)" | yarp rpc /ctpservice/right_arm/rpc
    sleep 2.0
    go_home_helperR 2.0
}

hello_right() {
    echo "ctpq time 1.5 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0 -11.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/right_arm/rpc
    sleep 2.0
    echo "ctpq time 0.5 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0  25.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time 0.5 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0 -11.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time 0.5 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0  25.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time 0.5 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0 -11.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/right_arm/rpc
    smile
    go_home
    smile
}

hello_both() {
    echo "ctpq time 1.5 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0 -11.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/left_arm/rpc
    echo "ctpq time 1.5 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0 -11.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/right_arm/rpc
    sleep 2.0

    echo "ctpq time 0.5 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0  25.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/left_arm/rpc
    echo "ctpq time 0.5 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0  25.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time 0.5 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0 -11.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/left_arm/rpc
    echo "ctpq time 0.5 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0 -11.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time 0.5 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0  25.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/left_arm/rpc
    echo "ctpq time 0.5 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0  25.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time 0.5 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0 -11.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/left_arm/rpc
    echo "ctpq time 0.5 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0 -11.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/right_arm/rpc

    smile
    go_home_helper 2.0
    smile
}

show_muscles() {
    echo "ctpq time 1.5 off 0 pos (-27.0 78.0 -37.0 33.0 -79.0 0.0 -4.0 26.0 27.0 0.0 29.0 59.0 117.0 87.0 176.0 250.0)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time 1.5 off 0 pos (-27.0 78.0 -37.0 33.0 -79.0 0.0 -4.0 26.0 27.0 0.0 29.0 59.0 117.0 87.0 176.0 250.0)" | yarp rpc /ctpservice/left_arm/rpc
    echo "ctpq time 1.0 off 0 pos (-27.0 78.0 -37.0 93.0 -79.0 0.0 -4.0 26.0 67.0 0.0 99.0 59.0 117.0 87.0 176.0 250.0)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time 1.0 off 0 pos (-27.0 78.0 -37.0 93.0 -79.0 0.0 -4.0 26.0 67.0 0.0 99.0 59.0 117.0 87.0 176.0 250.0)" | yarp rpc /ctpservice/left_arm/rpc
    sleep 3.0
    smile
    go_home_helper 2.0
}

show_muscles_left() {
    echo "ctpq time 1.5 off 0 pos (-27.0 78.0 -37.0 33.0 -79.0 0.0 -4.0 26.0 27.0 0.0 29.0 59.0 117.0 87.0 176.0 250.0)" | yarp rpc /ctpservice/left_arm/rpc
    echo "ctpq time 1.0 off 0 pos (-27.0 78.0 -37.0 93.0 -79.0 0.0 -4.0 26.0 67.0 0.0 99.0 59.0 117.0 87.0 176.0 250.0)" | yarp rpc /ctpservice/left_arm/rpc
    sleep 3.0
    smile
    go_home_helperL 2.0
}

show_iit() {
    echo "ctpq time 1.5 off 0 pos (-27.0 64.0 -30.0 62.0 -58.0 -32.0 4.0 17.0 11.0 21.0 29.0 8.0 9.0 5.0 11.0 1.0)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time 1.5 off 0 pos (-27.0 64.0 -30.0 62.0 -58.0 -32.0 4.0 17.0 11.0 21.0 29.0 8.0 9.0 5.0 11.0 1.0)" | yarp rpc /ctpservice/left_arm/rpc

    sleep 3.0
    smile

    go_home
}

show_agitation() {

    echo "ctpq time 1.0 off 0 pos (0.0 0.0 -12.0)" | yarp rpc /ctpservice/torso/rpc

    echo "bind pitch -10.0 0.0" | yarp rpc /iKinGazeCtrl/rpc
    sleep 0.2
    echo "bind roll 0.0 0.0" | yarp rpc /iKinGazeCtrl/rpc
    sleep 0.2
    echo "bind yaw 0.0 0.0" | yarp rpc /iKinGazeCtrl/rpc
    sleep 0.2

    gaze "look -30.0 0.0 5.0"
    sleep 1.5
    gaze "look 30.0 0.0 5.0"
    sleep 1.5
    gaze "look -30.0 0.0 5.0"
    sleep 1.5
    gaze "look 30.0 0.0 5.0"
    sleep 1.5

    echo "clear pitch" | yarp rpc /iKinGazeCtrl/rpc
    sleep 0.2
    echo "clear roll" | yarp rpc /iKinGazeCtrl/rpc
    sleep 0.2
    echo "clear yaw" | yarp rpc /iKinGazeCtrl/rpc
    sleep 0.2

    echo "ctpq time 1.0 off 0 pos (0.0 0.0 0.0)" | yarp rpc /ctpservice/torso/rpc
}

question() {
    echo "ctpq time 1.5 off 0 pos (-39.0 37.0 -17.0 53.0 -47.0 14.0 -2.0 -1.0 8.0 45 3.4 2.4 2.2 0.0 6.8 17)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time 1.5 off 0 pos (-39.0 37.0 -17.0 53.0 -47.0 14.0 -2.0 -1.0 8.0 45 3.4 2.4 2.2 0.0 6.8 17)" | yarp rpc /ctpservice/left_arm/rpc
    sleep 3.0
    go_home
}

question_left() {
    echo "ctpq time 1.5 off 0 pos (-39.0 37.0 -17.0 53.0 -47.0 14.0 -2.0 -1.0 8.0 45 3.4 2.4 2.2 0.0 6.8 17)" | yarp rpc /ctpservice/left_arm/rpc
    go_home_helperL 1.5
}

question_right() {
    echo "ctpq time 1.5 off 0 pos (-39.0 37.0 -17.0 53.0 -47.0 14.0 -2.0 -1.0 8.0 45 3.4 2.4 2.2 0.0 6.8 17)" | yarp rpc /ctpservice/right_arm/rpc
    go_home_helperR 1.5
}

talk_mic() {
    #breathers "stop"
    sleep 1.0
    echo "ctpq time $1 off 0 pos (-47.582418 37.967033 62.062198 107.868132 -32.921661 -12.791209 -0.571429 0.696953 44.352648 14.550271 86.091537 52.4 64.79118 65.749353 62.754529 130.184865)" | yarp rpc /ctpservice/right_arm/rpc
    sleep 1.0
    #breathers "start"
}


#######################################################################################
# SEQUENCE FUNCTIONS
#######################################################################################
sequence_01() { #Hi iCub! So happy to finally meet you!
  gaze "look 15.0 0.0 3.0"
  sleep 1.0
  sad
  speak "Why do you say finally? Don't you recognize me anymore? I am also your son!"
  sleep 3.0
  angry
  wait_till_quiet
  go_home_helper 2.0
}

sequence_02() { #What does your name mean?
    smile
    gaze "look-around 15.0 0.0 5.0"
    speak "My name means robot cub. Indeed I have the appearance of a child and I am learning to move and to do new things like childreen do!"
    wait_till_quiet
}
sequence_03() { #How old are you?
    gaze "look-around 15.0 0.0 5.0"
    speak "My first project is from two thousand and three. However I was born ten years ago here in Genova from the ideas of the engineers of the Italian Institute of Technology."
    # ten fingers
    echo "ctpq time 1.0 off 0 pos (-29.934066 15.098901 14.990769 93.351648 55.971316 -34.681319 -9.89011 23.084498 -1.354203 12.469105 -11.620051 0.0 1.126584 -0.011117 0.721644 5.060718)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time 1.0 off 0 pos (-30.021978 17.604396 12.003736 85.725275 67.533997 -51.384615 15.164835 15.825604 -2.594225 6.014222 14.851338 2.29419 17.957583 1.46216 12.812219 -2.64493)" | yarp rpc /ctpservice/left_arm/rpc
    sleep 5.0
    go_home_helper 2.0
    wait_till_quiet
    speak "I am very grateful to them, because they taught me everything I can do now."
    sleep 2.0
    wait_till_quiet
}
sequence_04() { #Who are you? describe yourself to me (DoF, emotions, skin)
    gaze "look-around 15.0 0.0 5.0"
    speak "As I told you before I am a robot cub, but I am special because I have a senstive skin and I can feel if someone touch me or tickle me"
    point_arms
    sleep 0.5 && blink
    wait_till_quiet
    speak "I can interact with the environment around me since I can move all the parts of my body! I can recognize objects and move or grasp them with my hands."
    #da ricontrolloare
    sleep 1.5
    echo "ctpq time 1.0 off 0 pos (-12.0 37.0 6.0 67.0 -52.0 -14.0 9.0    12.0 -6.0 37.0 2.0 0.0 3.0 2.0 1.0 0.0)" | yarp rpc /ctpservice/left_arm/rpc
    echo "ctpq time 1.0 off 0 pos (-13.0 29.0 18.0 59.0 -59.0 -12.0 -6.0    0.0 9.0 42.0 2.0 0.0 1.0 0.0 8.0 4.0)" | yarp rpc /ctpservice/right_arm/rpc
    sleep 4.0
    go_home_helper 1.2
    wait_till_quiet
    speak "I am also able to express emotions. You can see when I am sad!"
    sad
    speak "but don't worry, I am happy the most of the time!"
    smile
    wait_till_quiet
}
sequence_05() { #Do you have any brothers or sisters?
    gaze "look-around 15.0 0.0 5.0"
    speak "Yes! I have 2 brothers here with me, at IIT" #potrei mettere il due a numero con le dita
    right_two
    speak "And I have other 30 brothers around the world too"
    wait_till_quiet
    speak "Oh, and there also R one. But we do not speak of him, he is the"
    sleep 2.0
    skeptic
    speak "special cousin"
    sleep 4.0
    gaze "look-around 15.0 0.0 5.0"
    smile
    wait_till_quiet
}
sequence_06() { #Tell me a little bit about what you can do.
    gaze "look-around 15.0 0.0 5.0"
    speak "I can do a lot of things and every day I learn something new, thanks to the engineers at IIT"
    #movimento del braccio destro
    speak "For example I can stand on my feet and if someone touches me I will be on balance. I can't walk yet, but I will be able soon!"
    sleep 2.0
    echo "ctpq time 1.0 off 0 pos (-12.0 37.0 6.0 67.0 -52.0 -14.0 9.0    12.0 -6.0 37.0 2.0 0.0 3.0 2.0 1.0 0.0)" | yarp rpc /ctpservice/left_arm/rpc
    echo "ctpq time 1.0 off 0 pos (-13.0 29.0 18.0 59.0 -59.0 -12.0 -6.0    0.0 9.0 42.0 2.0 0.0 1.0 0.0 8.0 4.0)" | yarp rpc /ctpservice/right_arm/rpc
    sleep 3.0
    go_home_helper 1.2
    wait_till_quiet
    speak "My vision is improving fast too! Now I can recognize objects if you show them to me!"
    point_eye
    wait_till_quiet
    speak "I can learn new types of objects if you teach me and I will be able to tell you where these objects are around me, soon!"
    smile
    speak "I am also learning how to do yoga and tai chi!"
    smile && blink
    wait_till_quiet
}
sequence_07() { #Why was it important to build you similar to a human being?
    gaze "look-around 15.0 0.0 5.0"
    speak "Because together we can learn how human like creatures learn and behave in a complex environment."
    wait_till_quiet
    speak "Until some yars ago I didn't even know how to stand up. Now that I've learnt it, engineers are studying why it works with my body and how it can help other poeple."
    sleep 5.0
    show_muscles
    speak "Engineers are also studying how I can learn to recognize objects with my two eyes. In the future all this will help building prosthetic systems for vision and locomotion."
    smile && blink
    wait_till_quiet
}
sequence_08() { #What are the challenges of artificial intelligence?
    gaze "look-around 15.0 0.0 5.0"
    thinking
    speak "Well this is a difficult question!"
    wait_till_quiet
    speak "I think that the challanges of artificial intelligence are here!"
    point_ear_right
    wait_till_quiet
    speak "The challange to me is to improve the understanding of the reality around me through vision"
    point_eye
    wait_till_quiet
    speak "touching things and exploring the environment"
    #braccio destro per mostrare ambiente circostante
    echo "ctpq time 1.0 off 0 pos (-31.0 50.0 -21.0 42.0 -58.5 2.07 -1.7 18.5 40.3 -0.5 -1.8 -0.4 -1.2 -0.01 1.1 1.3)" | yarp rpc /ctpservice/right_arm/rpc
    sleep 2.0
    go_home_helperR 2.0
    wait_till_quiet
    speak "This will enhance my ability to interact with the surroundings and humans."
    wait_till_quiet
}
sequence_09() { #Who is better iCub or R1?
    gaze "look-around 15.0 0.0 5.0"
    speak "You should not ask me, I am a bit biased!"
    wait_till_quiet
    speak "Even if I like r one very much, I am the best! Can r one do this?"

    wait_till_quiet
}
sequence_10() { #Thank you iCub for your time
    gaze "look-around 15.0 0.0 5.0"
    speak "You are welcome! And thank you too!"
    wait_till_quiet
    speak "Go in peace"
    urbi_et_orbi
    wait_till_quiet
}


#######################################################################################
# "MAIN" FUNCTION:                                                                    #
#######################################################################################
echo "********************************************************************************"
echo ""

$1 "$2"

if [[ $# -eq 0 ]] ; then
    echo "No options were passed!"
    echo ""
    usage
    exit 1
fi
