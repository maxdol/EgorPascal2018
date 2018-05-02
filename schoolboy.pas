program schoolboy;
uses GraphABC;
uses Timers;
const windowWidth : integer = 1000;
var boyPosition : integer;
var running : boolean;
var boySpeed : integer;

procedure KeyDown(Key: integer);
begin
   case Key of
    VK_Left:  
      begin
        boyPosition := boyPosition - 2 * boySpeed;
        if boyPosition < 0 then
          boyPosition := windowWidth;
      end;
    VK_Right: 
      begin
        boyPosition := boyPosition + 2 * boySpeed;
        if boyPosition > windowWidth then
          boyPosition := 0;
      end;
    VK_ControlKey : boySpeed := 10;
    VK_Space : running := false;
   end;
end;

procedure KeyUp(Key: integer);
begin
   case Key of
    VK_ControlKey : boySpeed := 1;
   end;
end;

begin
  boyPosition := floor(windowWidth / 2);
  running := true;
  boySpeed := 1;
  var window := new GraphABCWindow();
  window.SetSize(windowWidth, 700);
  window.Caption := 'Pupil game';
  window.CenterOnScreen;
  OnKeyDown := KeyDown;
  OnKeyUp := KeyUp;

  while running do
  begin
    LockDrawing;
    window.Clear;
    DrawCircle(boyPosition, 50, 40);
    Redraw;
    Sleep(10);
  end;
  
  window.Close;
end.