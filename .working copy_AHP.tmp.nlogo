extensions [ matrix ]

globals [
  selected-car   ; the currently selected car
  lanes          ; a list of the y coordinates of different lanes
  broken-car     ; the currently selected broken-car
  temp           ; the variable to count the number of lane-changes

  criteria-matrix  ; matrix to store the criteria weights
  weights   ; weights to be considered for all decisions

  ; variables to store the weights for all decisions for AHP model
  deci_1_we ; decision_1_weights
  deci_2_we ; decision_2_weights
  deci_3_we ; decision_3_weights
  deci_4_we ; decision_4_weights
  ; end
]

turtles-own [
  speed         ; the current speed of the car
  top-speed     ; the maximum speed of the car (different for all cars)
  target-lane   ; the desired lane of the car
  patience      ; the driver's current level of patience

  counter       ; keeps the counter for lane change
  traveled      ; total distance travelled by the car
  recorded

  changing-lanes        ; variable to make sure that only valid lane-changes are calculated
  distance-in-lanes     ; array that stores the distance covered in that lane

  old-xcor      ; variable to keep track of the distance travelled
  old-ycor      ; variable to keep track of the last road that the car drove on

  detector      ; variable to run analysis that makes sure that the variable is correctly recorded
]

to setup
  clear-all
  set-default-shape turtles "car"
  draw-road
  create-or-remove-cars
  set selected-car one-of turtles
  set broken-car one-of turtles        ; randomly select a car and break it down to mimic traffic
  ask selected-car [ set color red ]
  ask broken-car [set color gray ]
  reset-ticks

  ; code to initialise the criterion matrix to make AHP work

  ; set criteria-matrix matrix:from-row-list [ [1 2 1 2.67] [0.5 1 0.5 1.33] [1 2 1 1.67] [0.375 0.75 0.375 1] ]

  set weights [ ]



end

to create-or-remove-cars

  ; make sure we don't have too many cars for the room we have on the road
  let road-patches patches with [ member? pycor lanes ]
  if number-of-cars > count road-patches [
    set number-of-cars count road-patches
  ]

  ; initialize all the variables for individual cars
  create-turtles (number-of-cars - count turtles) [
    set color car-color
    move-to one-of free road-patches
    set target-lane pycor
    set distance-in-lanes n-values number-of-lanes [1]
    set heading 90
    set top-speed 0.5 + random-float 0.5
    set speed 0.5
    set counter 0
    set old-xcor -20
    set old-ycor pycor
    set patience random max-patience
    set detector 0
    set changing-lanes false
  ]

  if count turtles > number-of-cars [
    let n count turtles - number-of-cars
    ask n-of n [ other turtles ] of selected-car [ die ]
  ]

end

to-report free [ road-patches ] ; turtle procedure
  let this-car self
  report road-patches with [
    not any? turtles-here with [ self != this-car ]
  ]
end

to draw-road
  ask patches [
    ; the road is surrounded by green grass of varying shades
    set pcolor green - random-float 0.5
  ]
  set lanes n-values number-of-lanes [ n -> number-of-lanes - (n * 2) - 1 ]
  ask patches with [ abs pycor <= number-of-lanes ] [
    ; the road itself is varying shades of grey
    set pcolor grey - 2.5 + random-float 0.25
  ]
  draw-road-lines
end

to draw-road-lines
  let y (last lanes) - 1 ; start below the "lowest" lane
  while [ y <= first lanes + 1 ] [
    if not member? y lanes [
      ; draw lines on road patches that are not part of a lane
      ifelse abs y = number-of-lanes
        [ draw-line y yellow 0 ]  ; yellow for the sides of the road
        [ draw-line y white 0.5 ] ; dashed white between lanes
    ]
    set y y + 1 ; move up one patch
  ]
end

to draw-line [ y line-color gap ]
  ; We use a temporary turtle to draw the line:
  ; - with a gap of zero, we get a continuous line;
  ; - with a gap greater than zero, we get a dasshed line.
  create-turtles 1 [
    setxy (min-pxcor - 0.5) y
    hide-turtle
    set color line-color
    set heading 90
    repeat world-width [
      pen-up
      forward gap
      pen-down
      forward (1 - gap)
    ]
    die
  ]
end


; every tick
to go

  create-or-remove-cars

  ask [ other turtles ] of broken-car [

    move-forward

    ; code to calculate the distance travelled from the last time it was calculated
    let dist 0
    if xcor >= old-xcor [ set dist xcor - old-xcor ]
    if old-xcor > xcor [ set dist xcor - old-xcor + 50 ]
    set old-xcor xcor
    set traveled traveled + dist

    ; code to update the distance travelled in the corresponding lane
    let lane-loc position ycor lanes
    if (is-number? lane-loc) [
      let temp-dist item lane-loc distance-in-lanes
      set distance-in-lanes replace-item lane-loc distance-in-lanes (temp-dist + dist)
    ]

  ]

  ask broken-car [
    break-down-car
  ]

  ; change lane for a car with patience less than 0
  ask turtles with [ patience <= 0 ] [
    set recorded traveled
    choose-new-lane
    set changing-lanes true    ; set it true, so it stops counting for lane-change until reached
  ]

  ; turtles moving to target lanes are instructed to call move-to-target-lane
  ask turtles with [ ycor != target-lane and changing-lanes = true] [
    move-to-target-lane
  ]

  ; function that counts the lane change the first time it reached the target lane
  ask turtles with [ ycor = target-lane and changing-lanes = true] [
    set counter counter + 1
    set changing-lanes false    ; this makes sure that its only counted once
    set old-ycor target-lane    ; useful for 4th decision
    set detector recorded
  ]

  tick

  ; procedure to pick a car to break down to mimic traffic
  if ticks mod 90 = 0 [
    ask broken-car [ set color car-color ]
    ask selected-car [ set color red ]
    set broken-car one-of turtles
    ask broken-car [ set color gray ]
    ask broken-car [ break-down-car ]
  ]

end

to move-forward ; turtle procedure
  set heading 90
  speed-up-car ; we tentatively speed up, but might have to slow down
  let blocking-cars other turtles in-cone (1 + speed) 45 with [ y-distance <= 1 ]
  let blocking-car min-one-of blocking-cars [ distance myself ]

  ; if there is a car blocking your way
  if blocking-car != nobody [
    ; match the speed of the car ahead of you and then slow
    ; down so you are driving a bit slower than that car.
    set speed [ speed ] of blocking-car

    if blocking-car = broken-car [ set speed 0 ]
    if speed > 0 [ slow-down-car ]
    if speed = 0 [ set patience -1 ]   ; doing this to make sure that the car choses a new lane

  ]

  forward speed
end

to break-down-car ; turtle procedure
  set speed 0
end

to slow-down-car ; turtle procedure
  set speed (speed - deceleration)
  if speed < 0 [ set speed deceleration ]
  ; every time you hit the brakes, you loose a little patience
  ifelse patience > 0 [ set patience patience - 1 ] [ set patience 0 ]
end

to speed-up-car ; turtle procedure
  set speed (speed + acceleration)
  if speed > top-speed [ set speed top-speed ]
end

; decision 1 is to choose the new lane that is the nearest to the one that you are on
; decision 2 is to choose the lane that has the minimum number of cars on it atm
; decision 3 is to choose the lane that you got to travel the most in other than yours
; decision 4 could be a variation to 2 where lane is changed based on how many cars in front of you
; decision 5 could be a ML model which makes the prediction of which lane to pick to travel
;            as far as possible without having to change lanes again
to choose-new-lane ; turtle procedure

  ; get all the lanes other than the one that you are standing on
  let other-lanes remove ycor lanes



  if not empty? other-lanes [

    let deci_1_lanes invert-values lanes-for-deci-1 other-lanes
    let deci_2_lanes invert-values lanes-for-deci-2 other-lanes
    let deci_3_lanes lanes-for-deci-3 other-lanes
    let deci_4_lanes invert-values lanes-for-deci-4 other-lanes

    ; changes to a lane that is nearest to the current one
    if (decision = 1) [
      set target-lane get-target-lane deci_1_lanes other-lanes
    ]

    ; changes to a lane that has the minimum number of cars in it at that time
    if (decision = 2) [
      set target-lane get-target-lane deci_2_lanes other-lanes
    ]

    ; changes to a lane where the car has travelled the most in
    if (decision = 3) [
      set target-lane get-target-lane deci_3_lanes other-lanes
    ]

    if (decision = 4) [
      set target-lane get-target-lane deci_4_lanes other-lanes
    ]

    set deci_1_we set-weights deci_1_lanes 1
    set deci_2_we set-weights deci_2_lanes 2
    set deci_3_we set-weights deci_3_lanes 3
    set deci_4_we set-weights deci_4_lanes 4

    if (decision = 5) [

      let values get-value
      ; show values
      set target-lane get-target-lane values other-lanes

    ]

    ;]

    set patience max-patience

    ;if (speed != 0) [set patience max-patience]   ; the car is now moving to a new lane with max-patience
    ;if (speed <= 0) [set patience 0]  ; if the speed is <= 0, then wait because it could be edge case (PLEASE WRITE A BETTER EXPLAINATION)
  ]

end

to-report lanes-for-deci-4 [other-lanes]
  let current-xcor xcor
  let field-of-view 15
  let left-xcor field-of-view - 50 + xcor
  report map [ y-tar -> (count turtles with [ ycor = y-tar and (xcor < left-xcor or xcor > current-xcor) ]) + 1 ] other-lanes
end

to-report lanes-for-deci-3 [other-lanes]
  let temp-dist-lanes distance-in-lanes     ; make a temporary array for future modification to that
  let temp-idx position old-ycor lanes      ; get the index number for the lane that the car is in right now
  set temp-dist-lanes remove-item temp-idx temp-dist-lanes    ; delete the distance travelled on the current lane before making a decision
  report temp-dist-lanes
end

to move-to-target-lane ; turtle procedure
  set heading ifelse-value target-lane < ycor [ 180 ] [ 0 ]
  let blocking-cars other turtles in-cone (1 + abs (ycor - target-lane)) 180 with [ x-distance <= 1 ]
  let blocking-car min-one-of blocking-cars [ distance myself ]
  ifelse blocking-car = nobody [
    forward 0.2
    set ycor precision ycor 1 ; to avoid floating point errors
  ] [
    ; slow down if the car blocking us is behind, otherwise speed up
    ifelse towards blocking-car <= 180 [ slow-down-car ] [ speed-up-car ]
  ]
end

to-report x-distance
  report distancexy [ xcor ] of myself ycor
end

to-report y-distance
  report distancexy xcor [ ycor ] of myself
end

to select-car
  ; allow the user to select a different car by clicking on it with the mouse
  if mouse-down? [
    let mx mouse-xcor
    let my mouse-ycor
    if any? turtles-on patch mx my [
      ask selected-car [ set color car-color ]
      set selected-car one-of turtles-on patch mx my
      ask selected-car [ set color red ]
      display
    ]
  ]
end

; function to stop the simulation if a specific number of turns are made
to-report number-of-lanes-changed
  ; if ticks > 100000 [ report true ]
  set temp [counter] of selected-car
  if temp > 100 [ report true ]
  report false
end

; make that that after the break down, all the cars still have random colors for genralisation
to-report car-color
  ; give all cars a blueish color, but still make them distinguishable
  report one-of [ blue cyan sky ] + 1.5 + random-float 1.0
end

to-report number-of-lanes
  ; To make the number of lanes easily adjustable, remove this
  ; reporter and create a slider on the interface with the same
  ; name. 8 lanes is the maximum that currently fit in the view.
  report 5
end

to-report trial
  report [ item 1 distance-in-lanes ] of selected-car
end

; Copyright 1998 Uri Wilensky.
; See Info tab for full copyright and license.

; function to report the nth root in netlogos

; thinking starts here

; What I want right now is a simple way to get the weights one and for all
; one way to do it is to make 4 seperate function and pass the values as required

; to-report

to-report get-value

  let temp-array n-values (number-of-lanes - 1) [i -> i]

  let decision-array map [ i -> (item i deci_1_we) + (item i deci_2_we) + (item i deci_3_we) + (item i deci_4_we) ] temp-array

  ; ; show decision-array

  report decision-array

end

to-report set-weights [values store]

  let wei 1
  ; show values
  if (store > 0) [ set wei item (store - 1) weights ]

 ; ; show wei

  let row-values map [ i -> row-value values i ] values
  let total reduce + row-values
  if (total = 0) [set total 1]
  let ans map [ i -> ( i / total ) * wei ] row-values
  ; ; show ans

  report ans

end

to-report row-value [values n]

  if (n = 0) [set n 1]
  let total reduce * values
  let num (total) / (n * n * n * n)
  report sqrt( sqrt ( num ) )

end

to-report get-target-lane [ values other-lanes ]

  let max-value max values
  let locations position max-value values
  report (item locations other-lanes)

end

to-report invert-values [values]
  let indexes n-values (number-of-lanes - 1) [i -> i]
  let locations filter [i -> (item i values) = 0] indexes
  if not empty? locations [

    ; replace-item 2 [2 7 4 5] 15
    foreach locations [x -> show replace-item x values 1]

  ]
  report map [i -> 1 / i ] values

end

to-report lanes-for-deci-1 [other-lanes]
  report map [ y -> abs (y - ycor) + 1 ] other-lanes
end

to-report lanes-for-deci-2 [other-lanes]
  report map [ y-tar ->  count turtles with [ycor = y-tar] + 1] other-lanes
end

; thinking ends here

@#$#@#$#@
GRAPHICS-WINDOW
225
10
1253
319
-1
-1
20.0
1
10
1
1
1
0
1
0
1
-25
25
-7
7
1
1
1
ticks
30.0

BUTTON
10
10
75
45
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
150
10
215
45
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
80
10
145
45
go once
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
10
190
215
223
select car
select-car
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

MONITOR
130
335
215
380
mean speed
mean [speed] of turtles
2
1
11

SLIDER
10
50
215
83
number-of-cars
number-of-cars
1
number-of-lanes * world-width
40.0
1
1
NIL
HORIZONTAL

PLOT
521
328
891
503
Car Speeds
Time
Speed
0.0
300.0
0.0
0.5
true
true
"" ""
PENS
"average" 1.0 0 -10899396 true "" "plot mean [ speed ] of turtles"
"max" 1.0 0 -11221820 true "" "plot max [ speed ] of turtles"
"min" 1.0 0 -13345367 true "" "plot min [ speed ] of turtles"
"selected-car" 1.0 0 -2674135 true "" "plot [ speed ] of selected-car"

SLIDER
10
85
215
118
acceleration
acceleration
0.001
0.01
0.006
0.001
1
NIL
HORIZONTAL

SLIDER
10
120
215
153
deceleration
deceleration
0.01
0.1
0.03
0.01
1
NIL
HORIZONTAL

PLOT
901
328
1271
503
Driver Patience
Time
Patience
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"average" 1.0 0 -10899396 true "" "plot mean [ patience ] of turtles"
"max" 1.0 0 -11221820 true "" "plot max [ patience ] of turtles"
"min" 1.0 0 -13345367 true "" "plot min [ patience ] of turtles"
"selected car" 1.0 0 -2674135 true "" "plot [patience] of selected-car"

BUTTON
10
225
215
258
follow selected car
follow selected-car
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
10
260
215
293
watch selected car
watch selected-car
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
10
295
215
328
reset perspective
reset-perspective
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

MONITOR
10
335
130
380
selected car speed
[ speed ] of selected-car
2
1
11

PLOT
226
329
516
504
Cars Per Lane
Time
Cars
0.0
0.0
0.0
0.0
true
true
"set-plot-y-range (floor (count turtles * 0.4)) (ceiling (count turtles * 0.6))\nforeach range length lanes [ i ->\n  create-temporary-plot-pen (word (i + 1))\n  set-plot-pen-color item i base-colors\n]" "foreach range length lanes [ i ->\n  set-current-plot-pen (word (i + 1))\n  plot count turtles with [ round ycor = item i lanes ]\n]"
PENS

SLIDER
10
155
215
188
max-patience
max-patience
1
100
30.0
1
1
NIL
HORIZONTAL

MONITOR
1263
66
1321
111
Turns
[counter] of selected-car
17
1
11

MONITOR
1263
10
1325
55
Turned 
[recorded] of selected-car
17
1
11

MONITOR
1263
121
1410
166
NIL
[xcor] of selected-car
17
1
11

MONITOR
1339
10
1401
55
Distance
[traveled] of selected-car
17
1
11

MONITOR
1340
67
1397
112
NIL
ticks
17
1
11

SLIDER
10
390
215
423
decision
decision
1
5
1.0
1
1
NIL
HORIZONTAL

MONITOR
1355
319
1413
364
NIL
trial
17
1
11

@#$#@#$#@
## WHAT IS IT?

This model is a more sophisticated two-lane version of the "Traffic Basic" model.  Much like the simpler model, this model demonstrates how traffic jams can form. In the two-lane version, drivers have a new option; they can react by changing lanes, although this often does little to solve their problem.

As in the Traffic Basic model, traffic may slow down and jam without any centralized cause.

## HOW TO USE IT

Click on the SETUP button to set up the cars. Click on GO to start the cars moving. The GO ONCE button drives the cars for just one tick of the clock.

The NUMBER-OF-CARS slider controls the number of cars on the road. If you change the value of this slider while the model is running, cars will be added or removed "on the fly", so you can see the impact on traffic right away.

The SPEED-UP slider controls the rate at which cars accelerate when there are no cars ahead.

The SLOW-DOWN slider controls the rate at which cars decelerate when there is a car close ahead.

The MAX-PATIENCE slider controls how many times a car can slow down before a driver loses their patience and tries to change lanes.

You may wish to slow down the model with the speed slider to watch the behavior of certain cars more closely.

The SELECT CAR button allows you to highlight a particular car. It turns that car red, so that it is easier to keep track of it. SELECT CAR is easier to use while GO is turned off. If the user does not select a car manually, a car is chosen at random to be the "selected car".

You can either [`watch`](http://ccl.northwestern.edu/netlogo/docs/dictionary.html#watch) or [`follow`](http://ccl.northwestern.edu/netlogo/docs/dictionary.html#follow) the selected car using the WATCH SELECTED CAR and FOLLOW SELECTED CAR buttons. The RESET PERSPECTIVE button brings the view back to its normal state.

The SELECTED CAR SPEED monitor displays the speed of the selected car. The MEAN-SPEED monitor displays the average speed of all the cars.

The YCOR OF CARS plot shows a histogram of how many cars are in each lane, as determined by their y-coordinate. The histogram also displays the amount of cars that are in between lanes while they are trying to change lanes.

The CAR SPEEDS plot displays four quantities over time:

- the maximum speed of any car - CYAN
- the minimum speed of any car - BLUE
- the average speed of all cars - GREEN
- the speed of the selected car - RED

The DRIVER PATIENCE plot shows four quantities for the current patience of drivers: the max, the min, the average and the current patience of the driver of the selected car.

## THINGS TO NOTICE

Traffic jams can start from small "seeds." Cars start with random positions. If some cars are clustered together, they will move slowly, causing cars behind them to slow down, and a traffic jam forms.

Even though all of the cars are moving forward, the traffic jams tend to move backwards. This behavior is common in wave phenomena: the behavior of the group is often very different from the behavior of the individuals that make up the group.

Just as each car has a current speed, each driver has a current patience. Each time the driver has to hit the brakes to avoid hitting the car in front of them, they loose a little patience. When a driver's patience expires, the driver tries to change lane. The driver's patience gets reset to the maximum patience.

When the number of cars in the model is high, drivers lose their patience quickly and start weaving in and out of lanes. This phenomenon is called "snaking" and is common in congested highways. And if the number of cars is high enough, almost every car ends up trying to change lanes and the traffic slows to a crawl, making the situation even worse, with cars getting momentarily stuck between lanes because they are unable to change. Does that look like a real life situation to you?

Watch the MEAN-SPEED monitor, which computes the average speed of the cars. What happens to the speed over time? What is the relation between the speed of the cars and the presence (or absence) of traffic jams?

Look at the two plots. Can you detect discernible patterns in the plots?

The grass patches on each side of the road are all a slightly different shade of green. The road patches, to a lesser extent, are different shades of grey. This is not just about making the model look nice: it also helps create an impression of movement when using the FOLLOW SELECTED CAR button.

## THINGS TO TRY

What could you change to minimize the chances of traffic jams forming, besides just the number of cars? What is the relationship between number of cars, number of lanes, and (in this case) the length of each lane?

Explore changes to the sliders SLOW-DOWN and SPEED-UP. How do these affect the flow of traffic? Can you set them so as to create maximal snaking?

Change the code so that all cars always start on the same lane. Does the proportion of cars on each lane eventually balance out? How long does it take?

Try using the `"default"` turtle shape instead of the car shape, either by changing the code or by typing `ask turtles [ set shape "default" ]` in the command center after clicking SETUP. This will allow you to quickly spot the cars trying to change lanes. What happens to them when there is a lot of traffic?

## EXTENDING THE MODEL

The way this model is written makes it easy to add more lanes. Look for the `number-of-lanes` reporter in the code and play around with it.

Try to create a "Traffic Crossroads" (where two sets of cars might meet at a traffic light), or "Traffic Bottleneck" model (where two lanes might merge to form one lane).

Note that the cars never crash into each other: a car will never enter a patch or pass through a patch containing another car. Remove this feature, and have the turtles that collide die upon collision. What will happen to such a model over time?

## NETLOGO FEATURES

Note the use of `mouse-down?` and `mouse-xcor`/`mouse-ycor` to enable selecting a car for special attention.

Each turtle has a shape, unlike in some other models. NetLogo uses `set shape` to alter the shapes of turtles. You can, using the shapes editor in the Tools menu, create your own turtle shapes or modify existing ones. Then you can modify the code to use your own shapes.

## RELATED MODELS

- "Traffic Basic": a simple model of the movement of cars on a highway.

- "Traffic Basic Utility": a version of "Traffic Basic" including a utility function for the cars.

- "Traffic Basic Adaptive": a version of "Traffic Basic" where cars adapt their acceleration to try and maintain a smooth flow of traffic.

- "Traffic Basic Adaptive Individuals": a version of "Traffic Basic Adaptive" where each car adapts individually, instead of all cars adapting in unison.

- "Traffic Intersection": a model of cars traveling through a single intersection.

- "Traffic Grid": a model of traffic moving in a city grid, with stoplights at the intersections.

- "Traffic Grid Goal": a version of "Traffic Grid" where the cars have goals, namely to drive to and from work.

- "Gridlock HubNet": a version of "Traffic Grid" where students control traffic lights in real-time.

- "Gridlock Alternate HubNet": a version of "Gridlock HubNet" where students can enter NetLogo code to plot custom metrics.

## HOW TO CITE

If you mention this model or the NetLogo software in a publication, we ask that you include the citations below.

For the model itself:

* Wilensky, U. & Payette, N. (1998).  NetLogo Traffic 2 Lanes model.  http://ccl.northwestern.edu/netlogo/models/Traffic2Lanes.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

Please cite the NetLogo software as:

* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

## COPYRIGHT AND LICENSE

Copyright 1998 Uri Wilensky.

![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Uri Wilensky at uri@northwestern.edu.

This model was created as part of the project: CONNECTED MATHEMATICS: MAKING SENSE OF COMPLEX PHENOMENA THROUGH BUILDING OBJECT-BASED PARALLEL MODELS (OBPML).  The project gratefully acknowledges the support of the National Science Foundation (Applications of Advanced Technologies Program) -- grant numbers RED #9552950 and REC #9632612.

This model was converted to NetLogo as part of the projects: PARTICIPATORY SIMULATIONS: NETWORK-BASED DESIGN FOR SYSTEMS LEARNING IN CLASSROOMS and/or INTEGRATED SIMULATION AND MODELING ENVIRONMENT. The project gratefully acknowledges the support of the National Science Foundation (REPP & ROLE programs) -- grant numbers REC #9814682 and REC-0126227. Converted from StarLogoT to NetLogo, 2001.

<!-- 1998 2001 Cite: Wilensky, U. & Payette, N. -->
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="acceleration_testing" repetitions="2" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>number-of-turns</exitCondition>
    <metric>[recorded] of selected-car</metric>
    <enumeratedValueSet variable="acceleration">
      <value value="0.002"/>
      <value value="0.003"/>
      <value value="0.005"/>
      <value value="0.006"/>
      <value value="0.007"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-patience">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-cars">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="deceleration">
      <value value="0.02"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="max_patience_testing" repetitions="2" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>number-of-turns</exitCondition>
    <metric>[recorded] of selected-car</metric>
    <enumeratedValueSet variable="max-patience">
      <value value="30"/>
      <value value="40"/>
      <value value="50"/>
      <value value="60"/>
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="acceleration">
      <value value="0.006"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-cars">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="deceleration">
      <value value="0.02"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="number_of_cars_testing" repetitions="2" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>number-of-turns</exitCondition>
    <metric>[recorded] of selected-car</metric>
    <enumeratedValueSet variable="max-patience">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="acceleration">
      <value value="0.006"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-cars">
      <value value="20"/>
      <value value="30"/>
      <value value="40"/>
      <value value="50"/>
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="deceleration">
      <value value="0.02"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="testing_oct_13" repetitions="15" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>number-of-lanes-changed</exitCondition>
    <metric>[recorded] of selected-car</metric>
    <enumeratedValueSet variable="max-patience">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="acceleration">
      <value value="0.006"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-cars">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="deceleration">
      <value value="0.03"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="max-patience">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="acceleration">
      <value value="0.006"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-cars">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="deceleration">
      <value value="0.05"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="testing_oct_14" repetitions="15" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>number-of-lanes-changed</exitCondition>
    <metric>[counter] of selected-car</metric>
    <enumeratedValueSet variable="max-patience">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="acceleration">
      <value value="0.006"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-cars">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="deceleration">
      <value value="0.03"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="testing_all_runs" repetitions="30" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>number-of-lanes-changed</exitCondition>
    <metric>[detector] of selected-car</metric>
    <enumeratedValueSet variable="decision">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="acceleration">
      <value value="0.006"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-patience">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-cars">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="deceleration">
      <value value="0.03"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
1
@#$#@#$#@