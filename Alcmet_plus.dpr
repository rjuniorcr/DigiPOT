program Alcmet_plus;

uses
  Forms,
  almect_form in 'almect_form.pas' {Form1},
  Unit2 in 'Unit2.pas' {fmajudas};

{$R *.res}

begin
  Application.Initialize;
  //Application.Title := 'Alcmet Plus';
  Application.Title := 'DigiPOT';
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(Tfmajudas, fmajudas);
  Application.Run;
end.
