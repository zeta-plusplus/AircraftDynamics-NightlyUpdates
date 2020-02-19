within AircraftDynamics.Aerodynamics.Components;

model DragObjSimple00
  //----- imports -----
  import Modelica.Constants;
  /********************************************************
         Declaration
    ********************************************************/
  //********** Package **********
  replaceable package Medium = Modelica.Media.Interfaces.PartialMedium annotation(
    choicesAllMatching = true);
  //********** Parameters **********
  parameter Real CDdes = 0.001 "drag coefficient" annotation(
    Dialog(group = "Characteristics"));
  parameter Modelica.SIunits.Area SrefDes = 0.1 "reference area" annotation(
    Dialog(group = "Geometry"));
  //********** Initialization Parameters **********
  //--- fluid_amb, port_amb ---
  parameter Modelica.SIunits.MassFlowRate m_flowAmb_init(displayUnit = "kg/s") = 0.0 "" annotation(
    Dialog(tab = "Initialization", group = "Fluid states"));
  parameter Modelica.SIunits.Pressure pAmb_init(displayUnit = "Pa") = 101.3 * 1000 "" annotation(
    Dialog(tab = "Initialization", group = "Fluid states"));
  parameter Modelica.SIunits.Temperature Tamb_init(displayUnit = "K") = 288.15 "" annotation(
    Dialog(tab = "Initialization", group = "Fluid states"));
  parameter Modelica.SIunits.SpecificEnthalpy hAmb_init(displayUnit = "J/kg") = 1.004 * 1000 * 288.15 "" annotation(
    Dialog(tab = "Initialization", group = "Fluid states"));
  //********** variables **********
  //---calculated parameters---
  Real CD(start = CDdes);
  Modelica.SIunits.Area Sref(start = SrefDes);
  //--- variables ---
  Modelica.SIunits.Force Df(start = 1.0);
  Modelica.SIunits.Force Fx;
  Modelica.SIunits.Force Fz;
  Modelica.SIunits.Velocity Vflow(start = 100);
  Real Mn(start = 0.5);
  Modelica.SIunits.Angle alpha;
  //--- objects ---
  Medium.BaseProperties fluid_amb(p.start = pAmb_init, T.start = Tamb_init, state.p.start = pAmb_init, state.T.start = Tamb_init, h.start = hAmb_init) "flow station of amb";
  //********** Interfaces **********
  Modelica.Fluid.Interfaces.FluidPort_a port_amb(redeclare package Medium = Medium, m_flow.start = m_flowAmb_init, h_outflow.start = hAmb_init) "" annotation(
    Placement(visible = true, transformation(origin = {-90, 60}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {-90, 60}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Blocks.Interfaces.RealOutput y_Df annotation(
    Placement(visible = true, transformation(origin = {110, 30}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {110, 40}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  AircraftDynamics.Types.InfoBus busFltStates1 annotation(
    Placement(visible = true, transformation(origin = {-90, -60}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {-90, -60}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Blocks.Interfaces.RealOutput y_Fz annotation(
    Placement(visible = true, transformation(origin = {0, 70}, extent = {{-10, -10}, {10, 10}}, rotation = 90), iconTransformation(origin = {0, 70}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
  Modelica.Blocks.Interfaces.RealOutput y_Fx annotation(
    Placement(visible = true, transformation(origin = {110, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {110, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
algorithm
//********** assignment, design parameter to variables (calculated parameters) **********
  CD := CDdes;
  Sref := SrefDes;
equation
  connect(alpha, busFltStates1.alpha) annotation(
    Line);
  connect(Mn, busFltStates1.Mn) annotation(
    Line);
//********** Connections, interface <-> internal variables **********
//-- port_amb --
  fluid_amb.p = port_amb.p;
  port_amb.h_outflow = fluid_amb.h;
  fluid_amb.h = actualStream(port_amb.h_outflow);
  fluid_amb.Xi = actualStream(port_amb.Xi_outflow);
  port_amb.m_flow = 1.0;
//-- else --
  y_Df = Df;
  y_Fx= Fx;
  y_Fz= Fz;
//********** Eqns describing physics **********
  Mn = Vflow / Medium.velocityOfSound(fluid_amb.state);
  Df = CD * Sref * 1 / 2 * fluid_amb.d * (sign(Vflow) * abs(Vflow) ^ 2.0);
  Fx= Df*cos(alpha);
  Fz= Df*sin(alpha);
  
  
  annotation(
    defaultComponentName="dragObj",
    Documentation(
    info = "<html>
<a href=\"modelica://AircraftDynamics/docs/Aerodynamics/Components/DragObjSimple00.html\"> Document html page</a>
<p> &emsp; </p>
<h4>example/demo models</h4>
  <ul>
  <li><a href=\"modelica://AircraftDynamics/Aerodynamics/Example/test/DragObjSimple00_test01\"> Aerodynamics/Example/test/DragObjSimple00_test01 </a> </li>
  </ul>
</html>"
    ),
    Icon(
      graphics = {Bitmap(origin = {2, -21}, extent = {{-102, 61}, {78, -19}}, imageSource = "/9j/4AAQSkZJRgABAQEAlgCWAAD/2wBDAAMCAgMCAgMDAwMEAwMEBQgFBQQEBQoHBwYIDAoMDAsKCwsNDhIQDQ4RDgsLEBYQERMUFRUVDA8XGBYUGBIUFRT/2wBDAQMEBAUEBQkFBQkUDQsNFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBT/wAARCADRAt4DASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwD9U6KKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKpaprenaHb+fqV/a6fB/z0upliX82IppOTshN21ZdpGXc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/wBk+C/D2l7en2PSoIcf98oK62igBqIsahUUKqjAVRgCnUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFAEF5Y2+oQGG6t4rmFuscyB1P4GuB179nf4beJMm88HaYjE5LWcZtST6kxFTXotFbU61Wi705OPo7GcqcKmk4pnztrn7DPw+1IFrG51jSXxwIblZE/EOpJ/76FcDrP8AwT/nXLaT4yjk9I7yxK4/4Ern/wBBr7Hor1qed5hS2qt+tn+ZxTy7Cz3h92h8GSfsc/FfwrM0mi6nYyn7wbTdRkgY4PGdypzwD1/Gmr4R/aV8I/6uXxJKi8hU1JLxcD0XzH/LFfetFdv+sOIl/Fpwl6r/AIJz/wBl0o/BKUfRnwXJ8dv2gfBsbHV7PUjDGMl9S0MKoA6neI1yPfNfOLMWYknJPJJr9UfjJqA0r4S+MrrOCmkXW0/7RiYL+pFfmb4R+H3iTx9efZvD+i3mqyZwzW8RKJ/vOflXp3Ir67JMZRr0qlb2caaTV7aJnh5hh6lOcKfO5+pW8LeLdZ8E6xDquhajPpl/F92a3bGR/dYdGU91IIPcV9m/Bn9tTSfEgt9K8bImi6o2I11KMf6JMemX7xE/ivU5XpXE/D39g/U77y7nxjrMemRdTY6biWbHoZD8qn6Bq+lvAPwH8D/DVY30bQbcXiAf6ddDzrgnHUO2duf9nA9q8vOcwyvER5Guea2cdLfPr9zOzL8LjKT5k+WPZ/5f8Md8rBlBByDyCKWiivzw+pCiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigCnq2k2WvabPp+o2sd7ZXC7JbeZdySLnOCO49qfp+m2mkWcdpY2sNlaxjCQW8YjRfooGBVmiq5nblvoKyvcKKKKkYUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQB//9k="), Text(origin = {-6, -46}, extent = {{-94, 6}, {106, -4}}, textString = "%name"), Text(origin = {0, 53}, extent = {{-10, 5}, {10, -5}}, textString = "Fz"), Text(origin = {62, 0}, extent = {{38, -4}, {20, 6}}, textString = "Fx"), Text(origin = {62, 40}, extent = {{38, -4}, {20, 6}}, textString = "D"), Text(origin = {-90, 45}, extent = {{-10, 5}, {10, -5}}, textString = "amb")}, coordinateSystem(extent = {{-100, -60}, {100, 60}}, initialScale = 0.1)),
    Diagram(coordinateSystem(extent = {{-100, -60}, {100, 60}})),
    __OpenModelica_commandLineOptions = "");
  
  
end DragObjSimple00;
