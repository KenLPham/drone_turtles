# Drone Turtles

drone -- control turtle remotely
gpsmove -- handle moving turtle using gps (requires gps constilation)
tps (turtle positioning system) -- low level api to handle positioning and movement
ts (turtle shell) -- helper function for turtle

## Message Protocol

Messages sent between the drone and controller are tables with a "type" and "body" value. The "type" value is used to identify how the message body should be handled.

## API

| Name        | Description                    |
| ----------- | ------------------------------ |
| forward     | Move drone forward             |
| back        | Move drone back                |
| up          | Move drone up                  |
| down        | Move drone down                |
| turnLeft    | Turn drone left                |
| turnRight   | Turn drone right               |
| goTo        | Move turtle with coordinates   |
| inspect     | Inspect space infront of drone |
| inspectUp   | Inspect space above the drone  |
| inspectDown | Inspect space below the drone  |
| detect      |                                |
| detectUp    |                                |
| detectDown  |                                |
