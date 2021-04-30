%Dan Kovari/Joshua Mendez



function [MC, TM, TC, TU] = launch_Controller
MC = MagnetController('COM8');
TM = TurnMonitor(MC);
TC = TurnController(MC,TM);
TU = TurnControlUI(TC);
end 