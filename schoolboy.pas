program schoolboy;

uses GraphABC;
uses Timers;


const 
  windowWidth : integer = 1000; { in pixels }
  stateSizeH : integer = 10; {state size horizontal, number of columns}
  stateSizeV : integer = 30; {state size vertical  , number of rows}
  VK_ESC : integer = 27;
  ExitFlag : integer = 0;
  ContinueFlag : integer = 1;
  InitialGeneratorSpeed : integer = 20;
  InitailGameSpeed : integer = 1;
  GameOverLimit : integer = 5;

var 
  boyPosition : integer = stateSizeH div 2;               { 1..stateSizeH }
  running : boolean = true;                               { false mean that we need to exit }
  gameOverAction : integer = -1;                          { -1 - no action, ExitFlag - exit, ContinueFlag - play again }
  boySpeed : integer = 1;                                 { horizontal speed of the boy, can be increased by pressing Ctrl }
  state : array [1..stateSizeH,1..stateSizeV] of integer; { main game state }
  score : integer = 0;                                    { positive score }
  deadCount : integer = 0;                                { number of looses }
  generatorSpeed : integer = InitialGeneratorSpeed;       { 1 .. 100 speed of figures generation }
  gameSpeed : integer = InitailGameSpeed;                 { 1 .. 10 speed of faling figures }

procedure UpdateScore(bottomFigure : integer; hasPlayer : boolean);
begin
  case bottomFigure of
    2 : if hasPlayer then 
          deadCount += 1;
    5 : begin
          if hasPlayer then
            score += 1
          else
            deadCount += 1;
        end;  
  end;

  if (deadCount = GameOverLimit) then
    running := false;

end;

procedure UpdateState(step : integer);
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
  if ((step mod 4) = 0) and (Random(1, 100) < generatorSpeed) then { need to add new failing figure }
  begin
    var figure : integer;
    if Random(1, 10) > 3 then
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
    VK_ESC        : running := false;
    {VK_F5         : UpdateState();        { manual update state : for debug}
   end;
end;

procedure FinalKeyDown(Key: integer);
begin
   case Key of
    VK_ESC   : gameOverAction := ExitFlag;
    VK_Enter : gameOverAction := ContinueFlag;
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
  score := 0;
  deadCount := 0;
  boyPosition := stateSizeH div 2;
  generatorSpeed := InitialGeneratorSpeed;
  gameSpeed := InitailGameSpeed;

  for var i := 1 to stateSizeH do
    for var j := 1 to stateSizeV do
      state[i,j] := 0;
end;

function ColumnCenterX(column : integer; columnWidth : integer; left : integer) : integer;
begin
  Result := left + (column - 1) * columnWidth + (columnWidth div 2);
end;

function GameSleepTime() : integer; { return milliseconds to sleep between steps }
begin
  Result := (15 - gameSpeed);
end;

function MinMax(x, min, max : integer) : integer;
begin
  Result := System.Math.Min(max, System.Math.Max(min, x));
end;

procedure UpdateSpeed(step : integer);
begin
  gameSpeed      := MinMax(step div 250, InitailGameSpeed, 10);
  generatorSpeed := MinMax(step div 80, 0, 95 - InitialGeneratorSpeed) + InitialGeneratorSpeed;
end;

procedure DrawScore(step : integer);
begin
  TextOut( 10, 10, String.Format('Счет: {0}', score ));
  TextOut( 10, 30, String.Format('Потери: {0} ({1})', deadCount, GameOverLimit));

  TextOut( 10, 60, String.Format('Скорость: {0}%', gameSpeed * 10));
  TextOut( 10, 80, String.Format('Нагрузка: {0}%', generatorSpeed));
  { debug info : }
  TextOut( 10, 100, String.Format('шаг: {0}', step));
  TextOut( 10, 120, String.Format('сон: {0}', GameSleepTime));
  
end;

procedure DrawFinalResult(window : GraphABCWindow);
begin
  LockDrawing;
  window.Clear();
  TextOut( (window.Width div 2) - 20, (window.Height div 2) - 10, 'Игра закончена!' );
  TextOut( (window.Width div 2) - 20, (window.Height div 2) + 10, String.Format('Итоговый счет: {0}', score ));
  TextOut( (window.Width div 2) - 20, (window.Height div 2) + 40, 'Нажмите "Esc" для выхода, "Enter", чтобы сыграть еще раз.');
  Redraw;
end;

function GiveUp() : boolean;
begin
  gameOverAction := -1;
  OnKeyDown := FinalKeyDown;

  while true do
  begin
    if (gameOverAction = ExitFlag) then
    begin
      Result := true;
      exit;
    end;

    if (gameOverAction = ContinueFlag) then
    begin
      running := true;
      OnKeyDown := KeyDown;
      Result := false;
      exit;
    end;

    Sleep(10);  
  end;    
end;


procedure Game( window : GraphABCWindow );
begin
  var step : integer = 0;
  var drawStep : integer = 0;
  
  while running do
  begin
    var left : integer = 200;
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
    DrawScore(step);

    drawStep += 1;
    if (drawStep = 10) then
    begin
      step += 1;
      drawStep := 0;
      UpdateState(step);
      UpdateSpeed(step);
    end;
    Redraw;
    Sleep(GameSleepTime());
  end;
end;

{ ------------------------- main -------------------------------------------------- }
begin
  var window := new GraphABCWindow();
  window.SetSize(windowWidth, 700);
  window.Caption := 'Ученик: ловите 5-ки, уворачивайтесь от 2-ек';
  window.IsFixedSize := true;
  window.CenterOnScreen;
  OnKeyDown := KeyDown;
  OnKeyUp := KeyUp;

  repeat
  begin
    InitState();
    Game(window);
    DrawFinalResult(window);
  end;
  until GiveUp();

  window.Close;
end.