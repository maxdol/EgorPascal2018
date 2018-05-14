program schoolboy;

uses GraphABC;
uses Timers;

const 
  windowWidth : integer = 1000; { in pixels }
  stateSizeH : integer = 10; {state size horizontal, number of columns}
  stateSizeV : integer = 30; {state size vertical  , number of rows}
  
var 
  boyPosition : integer = stateSizeH div 2;               { 1..stateSizeH }
  running : boolean = true;                               { false mean that we need to exit }
  boySpeed : integer = 1;                                 { horizontal speed of the boy, can be increased by pressing Ctrl }
  state : array [1..stateSizeH,1..stateSizeV] of integer; { main game state }
  score : integer = 0;                                    { positive score }
  deadCount : integer = 0;                                { number of looses }
  generatorSpeed : integer = 80;                          { 1 .. 100 speed of figures generation }

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
  for var i := 1 to stateSizeH do { iterate columns }
  begin
    UpdateScore(state[i,stateSizeV], boyPosition = i); { check bottom line: do we catch }

    { shift all figures 1 line down }
    for var j := stateSizeV downto 2 do
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
      
    state[Random(1, stateSizeH), 1] := figure;
  end;
end;

procedure KeyDown(Key: integer);
begin
   case Key of
    VK_Left:  
      begin
        boyPosition := boyPosition - 1 * boySpeed;
        if boyPosition < 1 then
          boyPosition := stateSizeH;
      end;
    VK_Right: 
      begin
        boyPosition := boyPosition + 1 * boySpeed;
        if boyPosition > stateSizeH then
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
  for var i := 1 to stateSizeH do
    for var j := 1 to stateSizeV do
      state[i,j] := 0;
end;

function ColumnCenterX(column : integer; columnWidth : integer; left : integer) : integer;
begin
  Result := left + (column - 1) * columnWidth + (columnWidth div 2);
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
    var columnWidth : integer := 80;
    LockDrawing;
    window.Clear;
    DrawCircle(ColumnCenterX(boyPosition, columnWidth, left), 650, (columnWidth div 2) - 10);
    for var i := 0 to stateSizeH do { draw mesh }
    begin
      MoveTo(left + i * columnWidth, 0);
      LineTo(left + i * columnWidth, 700);
    end;

    for var i := 1 to stateSizeH do { draw state }
    begin
      for var j := 1 to stateSizeV do
      begin
        if (state[i, j] <> 0) then
        begin
          TextOut(ColumnCenterX(i, columnWidth, left), 
                  j * 20, state[i, j]);
        end;
      end
    end;
    
    
    Redraw;
    Sleep(10);
  end;
  
  window.Close;
end.