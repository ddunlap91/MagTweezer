%test the C843class

%get (or create if needed) a reference to the C843class
c843 = C843class.getInstance();

%set the axis type for the 1st axis
c843.Axis(1).setAxisType('M-126.PD2');

fprintf('Linear Motor Position: %f\n',c843.Axis(1).Position);

c843.Axis(1).setPosition(0);
pause(1);
fprintf('Linear Motor Position: %f\n',c843.Axis(1).Position);

%set the axis type for the 2st axis
c843.Axis(2).setAxisType('C-150.PD');
c843.Axis(2).Reference();

fprintf('Rotation Motor Position: %f\n',c843.Axis(2).Position);

c843.Axis(2).setPosition(3600);
pause(1);
fprintf('Rotation Motor Position: %f\n',c843.Axis(2).Position);

%remove connections to C843
delete(c843);