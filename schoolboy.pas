program schoolboy;

uses GraphABC;
uses Timers;

const 
  windowWidth : integer = 1000;
  stateSize : integer = 10;
  
var 
  boyPosition : integer = stateSize div 2;
  running : boolean = true;
  boySpeed : integer = 1;
  state : array [1..stateSize,1..stateSize] of integer; { main game state}
  score : integer = 0;     { positive score}
  deadCount : integer = 0; { number of looses}
  generatorSpeed : integer = 80; { 1 .. 100 speed of figures generation }

procedure UpdateScore(bottomFigure : integer; hasPlayer : boolean);
begin
  case bottomFigure of
    2 : if hasPlayer then 
          deadCount += 1;
    5 : if hasPlayer then
          score += 1;
        else
          deadCount += 1;
  end;        
end;

procedure UpdateState();
begin
  for var i := 1 to stateSize do { iterate columns }
  begin
    UpdateScore(state[i,stateSize], boyPosition = i); { check bottom line: do we catch }

    { shift all figures 1 line down }
    for var j := stateSize downto 2 do
    begin
      state[i,j] := state[i,j-1];
    end;
    state[i,1] := 0;
  end;    

  {generate new figures}
  if Random(1, 100) < generatorSpeed then { need to add new failing figure }
  begin
    var figure : integer;
    if Random(1, 10) > 7 then
      figure := 5
    else
      figure := 2;
      
    state[Random(1, stateSize), 1] := figure;
  end;
end;

procedure KeyDown(Key: integer);
begin
   case Key of
    VK_Left:  
      begin
        boyPosition := boyPosition - 1 * boySpeed;
        if boyPosition < 1 then
          boyPosition := stateSize;
      end;
    VK_Right: 
      begin
        boyPosition := boyPosition + 1 * boySpeed;
        if boyPosition > stateSize then
          boyPosition := 1;
      end;
    VK_ControlKey : boySpeed := 3;
    VK_Space : running := false;
    VK_Enter : UpdateState(); { manual update state : for debug}
   end;
end;

procedure KeyUp(Key: integer);
begin
   case Key of
    VK_ControlKey : boySpeed := 1;
   end;
end;

procedure InitState();
begin
  for var i := 1 to stateSize do
    for var j := 1 to stateSize do
      state[i,j] := 0;
end;

{ ------------------------- main -------------------------------------------------- }
begin
  var window := new GraphABCWindow();
  window.SetSize(windowWidth, 700);
  window.Caption := 'Pupil game';
  window.IsFixedSize := true;
  window.CenterOnScreen;
  OnKeyDown := KeyDown;
  OnKeyUp := KeyUp;
  
  InitState();

  while running do
  begin
    var left : integer = 100;
    var columnWidth : integer := 50;
    LockDrawing;
    window.Clear;
    DrawCircle(left + boyPosition * columnWidth, 650, columnWidth - 10);
    for var i := 0 to stateSize do
    begin
      MoveTo(left + i * columnWidth, 0);
      LineTo(left + i * columnWidth, 700);
    end;
    
    
    Redraw;
    Sleep(10);
  end;
  
  window.Close;
end.