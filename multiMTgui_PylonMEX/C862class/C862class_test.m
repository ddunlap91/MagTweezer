%test the C862class

%get (or create if needed) a reference to the C843class
c862 = C862class.getInstance();
c862.ConnectCOM('COM1');

%set the axis type for the 1st axis
c862.Axis(2).setAxisType('M-126.PD2');
c862.Axis(2).Reference();
fprintf('Linear Motor Position: %f\n',c862.Axis(2).Position);

c862.Axis(2).setPosition(5);
fprintf('Target Position: %f\n',c862.Axis(2).getTargetPosition);
c862.Axis(2).WaitForOnTarget();
fprintf('Linear Motor Position: %f\n',c862.Axis(2).Position);

%set the axis type for the 2st axis
c862.Axis(1).setAxisType('C-150.PD');
c862.Axis(1).Reference();

fprintf('Rotation Motor Position: %f\n',c862.Axis(1).Position);

c862.Axis(1).setPosition(360);
c862.Axis(1).WaitForOnTarget();
fprintf('Rotation Motor Position: %f\n',c862.Axis(1).Position);

%remove connections to C843
delete(c862);