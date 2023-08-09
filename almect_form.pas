{
Desenvolvedor: André Penha Soares Silva
Técnico em Eletrônica - Seção de Telecomunicações
CLA - Centro de Lançamento de Alcântara
98 99211-0109
andrepenha@gmail.com

Sofware DigiPOT-CLBI
O Alcmet Plus é uma aplicativo que recebe através da porta serIal os dados
transmitidos das sondas dos balões meteorológico via Digicora.
Os dados lidos são tratavos e exibidos na tela do aplicativo.
São também gravados num arquivo .TRN para posterior uso em simulações.
Simultaneamente a geração do arquivo .TRN ocorre a retransmissão dos dados
filtrados para outra porta serial ligada a um PC rodando o Potengi na SVO para
uso em campanhas de lançamento.

}

unit almect_form;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, unit2, ComCtrls, StdCtrls, ExtCtrls, CPort, Buttons, Math,
  CPortCtl;

type
  TForm1 = class(TForm)
    MainMenu1: TMainMenu;
    Arquivo1: TMenuItem;
    Ajuda1: TMenuItem;
    SobreAlcmetPlus1: TMenuItem;
    Sair1: TMenuItem;
    StatusBar1: TStatusBar;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    GroupBox1: TGroupBox;
    btnconfdigicora: TButton;
    btnabrirdigicora: TButton;
    btnfechardigicora: TButton;
    Memo1: TMemo;
    GroupBox2: TGroupBox;
    btnconfguara: TButton;
    btnabrirguara: TButton;
    btnfecharguara: TButton;
    Memo2: TMemo;
    CheckBox1: TCheckBox;
    ComPort1: TComPort;
    ComPort2: TComPort;
    CheckBox2: TCheckBox;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label1: TLabel;
    GroupBox3: TGroupBox;
    btniniciar: TButton;
    btnparar: TButton;
    Label2: TLabel;
    GroupBox4: TGroupBox;
    Edit1: TEdit;
    SpeedButton1: TSpeedButton;
    Memo3: TMemo;
    OpenDialog1: TOpenDialog;
    btniniciarenvio: TBitBtn;
    btnpausarenvio: TBitBtn;
    btnpararenvio: TBitBtn;
    Label11: TLabel;
    GroupBox5: TGroupBox;
    Memo4: TMemo;
    btnconfguaraarquivo: TButton;
    CheckBox3: TCheckBox;
    btnabrirguaraarquivo: TButton;
    btnfecharguaraarquivo: TButton;
    ComPort3: TComPort;
    Label12: TLabel;
    Label13: TLabel;
    CheckBox4: TCheckBox;
    Timer1: TTimer;
    Label14: TLabel;
    Label15: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Label16: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    Label26: TLabel;
    Label29: TLabel;
    Label30: TLabel;
    Label31: TLabel;
    Label32: TLabel;
    Label33: TLabel;
    Label34: TLabel;
    Label35: TLabel;
    Label36: TLabel;
    ComDataPacket1: TComDataPacket;
    ComLed1: TComLed;
    ComLed2: TComLed;
    procedure Sair1Click(Sender: TObject);
    procedure SobreAlcmetPlus1Click(Sender: TObject);
    procedure btnconfdigicoraClick(Sender: TObject);
    procedure btnconfguaraClick(Sender: TObject);
    procedure btnabrirdigicoraClick(Sender: TObject);
    procedure btnabrirguaraClick(Sender: TObject);
    procedure btnfechardigicoraClick(Sender: TObject);
    procedure btnfecharguaraClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btniniciarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnpararClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure btniniciarenvioClick(Sender: TObject);
    procedure btnconfguaraarquivoClick(Sender: TObject);
    procedure btnabrirguaraarquivoClick(Sender: TObject);
    procedure btnfecharguaraarquivoClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure btnpausarenvioClick(Sender: TObject);
    procedure btnpararenvioClick(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure ComDataPacket1Packet(Sender: TObject; const Str: String);
  private
    //
    { Private declarations }
  public
    //
    { Public declarations }
  end;

var
  Form1: TForm1;

  iniciado_gravacao: boolean;     // variavel global sobre status da gravacao em arquivo...
  sugestao_nome_arquivo: string;  // variavel global com sugestao para nome de arquivo a partir da leitura do cabeçalho (se conseguir detectar)...
  contador: integer;              // variavel global usada no controle da leitura do memo que é usado para enviar os dados do .trn para a serial do Potengi..

  buffer_acumulador: string;
  fim_texto_detect: boolean;

implementation

{$R *.dfm}

procedure TForm1.Sair1Click(Sender: TObject);
begin
close;
end;

procedure TForm1.SobreAlcmetPlus1Click(Sender: TObject);
begin
//fmajudas.visible:= true;
fmajudas.showmodal;  //só deixa trabalhar nesse formulário
                     //obriga o usuario a fechar a tela Sobre
                     //para voltar ao aplicativo
end;

procedure TForm1.btnconfdigicoraClick(Sender: TObject);
begin

comport1.ShowSetupDialog;

if comport1.Port <> '' then //só habilita "abrir conexao" se for selecionado uma porta
begin
  btnabrirdigicora.Enabled := True;
end;

end;

procedure TForm1.btnconfguaraClick(Sender: TObject);
begin

  comport2.ShowSetupDialog;
  if comport2.Port<>'' then //só habilita "abrir conexao" se for selecionado uma porta
  begin
    btnabrirguara.Enabled := True;
  end; //if..
end;

procedure TForm1.btnabrirdigicoraClick(Sender: TObject);
begin

try

//caractere de inicio de pacote
//0a
ComDataPacket1.StartString := #10;
//caractere de final de pacote
//0d
ComDataPacket1.StopString := #13;



// Abrindo a conexão serial com a Digicora
comport1.Open;
if comport1.Connected then
  begin
   statusbar1.Panels[0].text:='Conexão serial com Digicora estabelecida com sucesso - ('+comport1.Port+')';
   groupbox1.caption:= groupbox1.caption +' - Conectado : '+ comport1.Port;
   btnabrirdigicora.Enabled := False;
   btnconfdigicora.Enabled:=False;
   btnfechardigicora.Enabled := True;
   Memo1.Lines.clear;
   Memo2.Lines.clear;
   checkbox2.enabled:= true;
   btniniciar.enabled:= true;

  end
  else
    begin
      Memo1.Text := Memo1.Text + 'FALHA ao abrir conexão serial com ('+comport1.Port+')';
    end;
      Except on E : Exception do
        begin
          Memo1.Lines.clear;
          Memo1.Text := Memo1.Text + 'ERRO ao abrir conexão: Detalhes> '+E.Message;
        end;
    end;










end;

procedure TForm1.btnabrirguaraClick(Sender: TObject);
begin


try
// Abrindo a conexão serial com o Guará
comport2.Open;
if comport2.Connected then
  begin
   statusbar1.Panels[0].text:='Conexão serial com Potengi estabelecida com sucesso - ('+comport2.Port+')';
   groupbox2.caption:= groupbox2.caption +' - Conectado : '+ comport2.Port;
   btnabrirguara.Enabled := False;
   btnconfguara.Enabled:=False;
   btnfecharguara.Enabled := True;
   CheckBox1.enabled:= true;
   //Memo1.Lines.clear;
   //Memo2.Lines.clear;

  end
  else
    begin
      Memo2.Text := Memo2.Text + 'FALHA ao abrir conexão serial com ('+comport2.Port+')';
    end;
      Except on E : Exception do
        begin
          Memo2.Lines.clear;
          Memo2.Text := Memo2.Text + 'ERRO ao abrir conexão: Detalhes> '+E.Message;
        end;
    end;




end;

procedure TForm1.btnfechardigicoraClick(Sender: TObject);
begin

//Memo1.Lines.clear;

comport1.Close; //fecha a conexao serial com Digicora
if not comport1.Connected then
  begin
    statusbar1.Panels[0].text:= 'Conexão serial com Digicora finalizada com sucesso ('+comport1.Port+')';
    groupbox1.caption:= ' Conexao Digicora ';
    btnfechardigicora.Enabled := False;
    btnabrirdigicora.Enabled := False;
    btnconfdigicora.Enabled:=True;
    checkbox2.enabled:= false;
    btniniciar.enabled:=false;
  end
else
  begin
    Memo1.Text := Memo1.Text + 'Falha ao finalizar conexão serial.'
  end;



end;

procedure TForm1.btnfecharguaraClick(Sender: TObject);
begin

Memo2.Lines.clear;

comport2.Close; //fecha a conexao serial com guará
if not comport2.Connected then
  begin
    statusbar1.Panels[0].text:= 'Conexão serial com Potengi finalizada com sucesso ('+comport2.Port+')';
    groupbox2.caption:= ' Conexão Potengi ';
    btnfecharguara.Enabled := False;
    btnabrirguara.Enabled := False;
    btnconfguara.Enabled:=True;
    CheckBox1.enabled:= false;
  end
else
  begin
    Memo2.Text := Memo1.Text + 'Falha ao finalizar conexão serial.'
  end;




end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin

// Caso o usuario feche o programa sem fechar a conexão
comport1.Close;
comport2.Close;
comport3.Close;

end;

procedure TForm1.btniniciarClick(Sender: TObject);
var
  arq: TextFile; // declarando a variável "arq" do tipo arquivo texto

begin

iniciado_gravacao:= true;//setando em true a variavel global de controle de gravacao
btniniciar.enabled:= false;
btnparar.Enabled:= true;

try
  AssignFile(arq, 'ARQTMP.TRN'); //associa a variavel 'arq' a o arquivo fisico 'ARQTMP.TRN'
  Rewrite(arq); // se 'ARQTMP.TRN' já existir ele é criado novamente limpo, se nao existir é criado
  CloseFile(arq); // fecha o arquivo texto 'ARQTMP.TRN'
  except
  end;



{
Arquivo := TStringList.Create;
Arquivo.LoadFromFile('ARQTMP.TRN'); //carrega em 'Arquivo' o conteudo anterior do arquivo carregado
Arquivo.Add('linha1');
Arquivo.SavetoFile('ARQTMP.TRN');
Arquivo.Free; //para economizar memória
Arquivo:=Nil;
}

{ //trecho de estudo
while (contador_gravar <linhas_memo3) do
  begin
    Arquivo := TStringList.Create;
    Arquivo.LoadFromFile(nome_arq_tor);
    Arquivo.Add(Memo3.Lines.Strings[contador_gravar]);
    Arquivo.SavetoFile(nome_arq_tor);
    Arquivo.Free; //para economizar memória
    Arquivo:=Nil;
    contador_gravar:= contador_gravar + 1;
  end;
}



end;

procedure TForm1.FormCreate(Sender: TObject);
begin


iniciado_gravacao:= false; //inicializando a variavel de controle de gravacao
sugestao_nome_arquivo:= 'arquivo.trn'; //iniciando o nome sugerido para o arquivo texto a ser gravado

contador:=0;//inicializacao da variavel contador usada na rotina de enviar o .trn para a serial do guará

buffer_acumulador:='';

fim_texto_detect:=false;
end;

procedure TForm1.btnpararClick(Sender: TObject);
var
//  arq1: TextFile; // declarando a variável "arq1" do tipo arquivo texto
//  arq2: TextFile; // declarando a variável "arq2" do tipo arquivo texto
linha: string;
nome_arquivo: string;

begin


iniciado_gravacao:= false;//variavel global de controle de gravacao indo para false, cancelando assim a insercao de dados no arquivo em disco
btnparar.Enabled:= false;


if comport1.Connected then
  begin
  btniniciar.Enabled:= true;
  end;


//recebendo dados de um inputbox
//no caso, será o arquivo que receberá os dados gravados no ARQTMP.TRN
nome_arquivo:= inputbox('Salvar','Digite o nome do arquivo .TRN',sugestao_nome_arquivo);


if nome_arquivo = '' then //para o caso do usuario só apagar o nome do arquivo na caixa de dialogo, ele salva em arquivo.trn
  begin
  nome_arquivo := 'arquivo.trn';
  end;




if FileExists('ARQTMP.TRN') then
  begin
    if not FileExists(nome_arquivo) then
      begin
        if CopyFile('ARQTMP.TRN', PAnsiChar(nome_arquivo), True) then //tem q converter para PAnsiChar a string nome_arquivo
          showmessage('Dados gravados no arquivo: '+nome_arquivo+' com sucesso');
      end
    else
      begin
        if MessageDlg('Foi encontrado um arquivo com o mesmo nome, deseja substituir o arquivo?', mtConfirmation,[mbyes,mbno],0)=mryes then
          begin
            if CopyFile('ARQTMP.TRN', PAnsiChar(nome_arquivo), False) then
              begin
                ShowMessage('Arquivo substituído com sucesso.');
                if comport1.Connected then
                  begin
                    btniniciar.Enabled:= true;
                    btnparar.Enabled:= false;
                  end;
              end;
          end
        else
          begin
            ShowMessage('#Atenção# - Os dados não foram salvos');
            btniniciar.Enabled:= false;
            btnparar.Enabled:= true;
          end;
      end;
  end;






{
//copia o conteudo de ARQTMP.TRN para ARQTMP_new.TRN
try
  AssignFile(arq1, 'ARQTMP.TRN'); //associa a variavel 'arq1' a o arquivo fisico 'ARQTMP.TRN'
  AssignFile(arq2, nome_arquivo); //associa a variavel 'arq2' a o arquivo fisico guardado na variavel 'nome_arquivo'

  Reset(arq1); //abre 'ARQTMP.TRN' para leitura e coloca o ponteiro no começo dele

  Rewrite(arq2); // se 'nome_arquivo' já existir ele é criado novamente limpo, se nao existir é criado
  Append(arq2); //abre um arquivo texto 'nome_arquivo' existente para extendê-lo

  if (IOResult <> 0) then // verifica o resultado da operação de abertura
    begin
      showmessage('Erro na abertura do arquivo !!!');
    end
  else
    begin
      // verifica se o ponteiro de arquivo atingiu a marca de final de arquivo
      while (not eof(arq1)) do
        begin
          readln(arq1, linha); //Lê uma linha do arquivo
          //write(arq2,linha); //tive probleme com write pq ele grava é simplesmente exclui o 0a que tenha no arquivo
          //writeln(arq2,linha); //tive probleme com writeln pq se tiver um '0a' ele acrescenta um '0d' por conta própria. ai a copia do arquivo nao fica igual.
        end;
         CloseFile(arq1);
         CloseFile(arq2);
         showmessage('Dados gravados no arquivo: '+nome_arquivo+' com sucesso');
     end;

  except
  end;
}




end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
var
arquivo: textFile;
linhasArq: String;

begin

Memo3.Clear;

//forma mais simples e rápida de carregar o .trn no memo
if (OpenDialog1.Execute) then
  begin
    if (OpenDialog1.FileName <> '') then //só roda se o usuario abrir algum arquivo na caixa de dialogo
      begin
        edit1.text:= OpenDialog1.FileName;
        try
        Memo3.Lines.LoadFromFile(OpenDialog1.FileName);
        btniniciarenvio.enabled:= true;
        checkbox3.enabled:= true;
        except
        Memo3.Lines.Add('Erro na abertura do arquivo !!!');
        end;

      end;
  end;


end;

procedure TForm1.btniniciarenvioClick(Sender: TObject);
begin

btniniciarenvio.enabled:= false;

btnpausarenvio.enabled:= true;
btnpararenvio.Enabled:= true;

//no inicio de toda transmissao via arquivo é enviada essa sequencia para evitar do guará travar
{
isso foi verificado na saída do alcmet na opcao de enviar arquivo.trn para o guará

   48   0  0.0 <--
   52   0  0.0 <--
   58   0  0.0 <--
   69   0  0.0 <--
   85   0  0.0 <-- até aqui é cabeçalho que o alcmet gera automatico
  112   0  0.0 <-- para evitar problemas no Guará
   49  90  1.0 <-- aqui em diante já é dado gerado a partir da leitura do arquivo .trn
   69  83  2.8
   80  76  4.4
   90  71  5.9
  101  66  7.1
  112  63  7.8

Esses valores iniciais são gerados porque o guará trava se receber leituras
iniciais diferentes de 48 m de altura
}


if (comport3.Connected) and  (checkbox4.checked=true) and (contador=0) then
  begin
    comport3.WriteStr('   48   0  0.0'+char(10));
    sleep(100);
    comport3.WriteStr('   52   0  0.0'+char(10));
    sleep(100);
    comport3.WriteStr('   58   0  0.0'+char(10));
    sleep(100);
    comport3.WriteStr('   69   0  0.0'+char(10));
    sleep(100);
    comport3.WriteStr('   85   0  0.0'+char(10));
    sleep(100);
    comport3.WriteStr('  112   0  0.0'+char(10));
    sleep(100);
  end;



timer1.enabled:= true;

end;

procedure TForm1.btnconfguaraarquivoClick(Sender: TObject);
begin

comport3.ShowSetupDialog;

if comport3.Port<>'' then //só habilita "abrir conexao" se for selecionado uma porta
begin
  btnabrirguaraarquivo.Enabled := True;
end;
end;

procedure TForm1.btnabrirguaraarquivoClick(Sender: TObject);
begin


try
// Abrindo a conexão serial com o Guará
comport3.Open;
if comport3.Connected then
  begin
   statusbar1.Panels[0].text:='Conexão serial com Guará estabelecida com sucesso - ('+comport3.Port+')';
   groupbox5.caption:= groupbox5.caption +' - Conectado : '+ comport3.Port;
   btnabrirguaraarquivo.Enabled := False;
   btnconfguaraarquivo.Enabled:=False;
   btnfecharguaraarquivo.Enabled := True;
   CheckBox4.enabled:= true;
  end
  else
    begin
      Memo4.Text := Memo4.Text + 'FALHA ao abrir conexão serial com ('+comport3.Port+')';
    end;
      Except on E : Exception do
        begin
          Memo4.Lines.clear;
          Memo4.Text := Memo4.Text + 'ERRO ao abrir conexão: Detalhes> '+E.Message;
        end;
    end;





end;

procedure TForm1.btnfecharguaraarquivoClick(Sender: TObject);
begin

Memo4.Lines.clear;

comport3.Close; //fecha a conexao serial com guará
if not comport3.Connected then
  begin
    statusbar1.Panels[0].text:= 'Conexão serial com Guará finalizada com sucesso ('+comport3.Port+')';
    groupbox5.caption:= ' Conexao Guará ';
    btnfecharguaraarquivo.Enabled := False;
    btnabrirguaraarquivo.Enabled := False;
    btnconfguaraarquivo.Enabled:=True;
    CheckBox4.enabled:= false;
  end
else
  begin
    Memo4.Text := Memo4.Text + 'Falha ao finalizar conexão serial.'
  end;





end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
buffer_dados: string;
linhas_memo: integer;

string_filtrada:string;

altitude: string;
direcao: string;
velocidade: string;

tamanho: integer;
cont: integer;
num_espacos: integer;

begin

//para ajustar a taxa de tranferência das linhas
if ( CheckBox3.Checked=true) then
  begin
    timer1.interval:=100;
  end
  else
  begin
    timer1.interval:=2000;
  end;

linhas_memo:= Memo3.Lines.Count; //contagem do numero de linhas do memo


//a variavel contador é global
if contador <linhas_memo then
    begin

      buffer_dados:= Memo3.Lines.Strings[contador];

      //para check do status do buffer_dados
      label12.caption:= buffer_dados;



      //62 é o tamanho da string com os dados das leituras da sondagem
      //length pega o tamanho da string
      //form1.caption:= inttostr(length(buffer_dados));
      if (Length(buffer_dados)=62) then
        begin
          altitude:= Copy(buffer_dados,16,8); //a partir o byte 16 copia 8 bytes
          direcao:= Copy(buffer_dados,51,5);
          velocidade:= Copy(buffer_dados,56,6);

          //removento os espaço das string capturadas de altitude, direcao e velocidade
          altitude:= StringReplace(altitude, ' ', '', [rfReplaceAll, rfIgnoreCase]);
          direcao:= StringReplace(direcao, ' ', '', [rfReplaceAll, rfIgnoreCase]);
          velocidade:= StringReplace(velocidade, ' ', '', [rfReplaceAll, rfIgnoreCase]);

          label17.caption:= altitude;
          label18.Caption:= direcao;
          label19.caption:= velocidade;

          string_filtrada:=''; //limpando a string_filtrada

          //montando a string filtrada de altitude
          //****************************************
          tamanho:= length(altitude);  //conta o numero de carateres da string
          num_espacos:= 5-tamanho; //numero de vezes que vai gerar espaços

          //acrescentando a string_filtrada o numero de espaços necessários
          for cont:= 1 to num_espacos do
            begin
              string_filtrada:= string_filtrada+' ';
            end;
          //atualizando string_filtrada
          string_filtrada:= string_filtrada + altitude;

          //montando a string filtrada de direcao
          //****************************************
          tamanho:= length(direcao);  //conta o numero de carateres da string
          num_espacos:= 4-tamanho; //numero de vezes que vai gerar espaços

          //acrescentando a string_filtrada o numero de espaços necessários
          for cont:= 1 to num_espacos do
            begin
              string_filtrada:= string_filtrada+' ';
            end;
          //atualizando string_filtrada
          string_filtrada:= string_filtrada + direcao;


          //montando a string filtrada de velocidade
          //****************************************
          tamanho:= length(velocidade);  //conta o numero de carateres da string
          num_espacos:= 5-tamanho; //numero de vezes que vai gerar espaços

          //acrescentando a string_filtrada o numero de espaços necessários
          for cont:= 1 to num_espacos do
            begin
              string_filtrada:= string_filtrada+' ';
            end;
          //atualizando string_filtrada
          string_filtrada:= string_filtrada + velocidade;

          if (string_filtrada<>'Hgt/MSLDirS peed') then //o cabeçalho tinha exatamente o mesmo tamanho do bloco de dados, por isso esses caracteres eram enviados indevidos. por isso usei esse if
            begin
              Memo4.Lines.Add(string_filtrada);
            end;

        end;


      //ele só tenta enviar  na serial se a serial estiver conectada e o checkbox 'enviar para guará' estiver em true
      if comport3.Connected and  checkbox4.checked=true then
        begin
          if  (string_filtrada <>'') then //evita de mandar char(10) em casos que buffers_dados_filtrado tá zerado
            begin
              //comport.WriteStr(buffer_dados); //sem quebra de linha e retorno de carro
              //comport.WriteStr(buffer_dados+char(13)+char(10));
              //char(10) line-feed LF   - hex (0a)
              //char(13) enter-CR (carriage return) - hex (0d)
              //para o guará não vai CR só o LF
              if (string_filtrada<>'Hgt/MSLDirS peed') then //o cabeçalho tinha exatamente o mesmo tamanho do bloco de dados, por isso esses caracteres eram enviados indevidos. por isso usei esse if
                begin
                  comport3.WriteStr(string_filtrada+char(10));
                  label15.caption:= string_filtrada;
                end;
            end;
        end;



      //para evitar problema de travamento,a cada 200 insercoes o memo é limpo
      if (Memo4.Lines.Count>=200) then
        begin
          memo4.clear;
        end;

      contador:= contador + 1;
    end
    else
      begin
        contador:=0;
        timer1.enabled:=false;
        Showmessage('Envio de Dados de Sondagem concluído');
        btniniciarenvio.enabled:= true;
        btnpausarenvio.enabled:= false;
        btnpararenvio.enabled:=false;
        label12.caption:= '  -  ';
      end;







end;

procedure TForm1.btnpausarenvioClick(Sender: TObject);
begin


if (btnpausarenvio.tag=0) then
  begin
    timer1.Enabled:=false;
    btnpausarenvio.tag:=1;
    btnpausarenvio.caption:= 'Continuar Envio';
  end
else
  begin
    timer1.Enabled:=true;
    btnpausarenvio.tag:=0;
    btnpausarenvio.caption:= 'Pausar Envio';
  end;



end;

procedure TForm1.btnpararenvioClick(Sender: TObject);
begin

timer1.enabled:= false;
contador:=0;
btniniciarenvio.enabled:= true;
btnpararenvio.enabled:=false;
btnpausarenvio.enabled:=false;


end;

procedure TForm1.PageControl1Change(Sender: TObject);
begin


//bloquei do acesso ao item ate nova versao do alcmet plus clbi
PageControl1.ActivePageIndex := 0;
//showmessage ('Este recurso não está disponível nesta Versão do Alcmet Plus CLBI');





{
recurso para impedir a mundaça de pagina
nao gostei muito mas posso usar em ultimo caso
}



//verifica qual o tabsheet ativo
if (PageControl1.ActivePageindex=1) then
  begin
    //impede mundança de página se tiverem conexões seriais ativas
    if (comport1.Connected=true) or (comport2.Connected=true)  then
      begin
        PageControl1.ActivePageIndex := 0;
        showmessage ('Não é permitido mudar de página agora - Existem conexões seriais ativas');
      end;
  end;

//verifica qual o tabsheet ativo
if (PageControl1.ActivePageindex=0) then
  begin
    //impede mundança de página se tiverem conexões seriais ativas
    if (comport3.Connected=true) then
      begin
        PageControl1.ActivePageIndex := 1;
        showmessage ('Não é permitido mudar de página agora - Existem conexões seriais ativas');
      end;
  end;




end;

procedure TForm1.ComDataPacket1Packet(Sender: TObject; const Str: String);
var
RxCount: Integer; //variavel para contar o numero de bytes que estão no buffer da serial
RxComport: String;//variável para armazenar os bytes do buffer da serial

tempo: string;
direcao: string;
velocidade: string;
altitude:string;
latitude:string;
longitude:string;

//variaveis exclusivas CLBI
ascrat: string;
pressure: string;
temp: string;
u: string;
v: string;
TD: string;

TD_celcius: double; //float para calculo do TD

tamanho: integer;
contador: integer;
num_espacos: integer;
string_filtrada:string;
string_filtrada_serial:string;

arq: TextFile; // declarando a variável "arq" do tipo arquivo texto

rxcomport_notnull:string;//dados seriais sem o NULL

dados_gravar:string; //dados tratados para gravacao

flag_barra: boolean; //variavel auxilar, vai para true se tiver "/" na string recebida

begin


label1.Caption:= inttostr(length(str));

Rxcomport := str;

//faz uma copia do rxcomport para outra variavel
rxcomport_notnull:= Rxcomport;

//removento o caractere NULL da string
//evita do memo travar se ele chegar a ser enviado
//pela digicora
while pos(char(0),rxcomport_notnull) > 0 do
  begin
    delete (rxcomport_notnull,pos(char(0),rxcomport_notnull),1);
  end;


buffer_acumulador:= buffer_acumulador+rxcomport_notnull;

label23.caption:= buffer_acumulador;
label28.caption:= inttostr(length(buffer_acumulador));



    //atualizando o memo de dados recebidos da Digicora
    //***************************************************
    Memo1.Lines.Add(buffer_acumulador);
    //Memo1.Text := Memo1.Text + Rxcomport_notnull;
    SendMessage(Memo1.Handle, WM_VSCROLL, SB_BOTTOM, 0); //manter o foco no final do memo

//procurando na string uma "/"
//se encontrar, exibe no memo mas nao trata
//indica final de sondagem
flag_barra:= false;
if (pos('/',rxcomport_notnull) > 0) then
  begin
    flag_barra:= true;
  end;


    //pequena validacao checando o tamanho do bloco de dados
    //só preenche o memo de retransmissao se o checkbox estiver em ON
    //verifica o tamanho do buffer_acumulador para testar integridade
    //pela analise da saida da digicora nova, a linha varia de 90, 91 e 92 caracteres
    //coloquei essa faixa (89 ate 95)para garantia de pequenas variacoes ainda válidas
if (checkbox2.checked=true) and (flag_barra=false) 
  and ((length(buffer_acumulador)>=89)
  and (length(buffer_acumulador)<=95)) then
      begin
        //label2.caption:= RxComport;

        tempo:= Copy(buffer_acumulador,1,5); //a partir o byte 1 copia 5 bytes
        altitude:= Copy(buffer_acumulador,26,10); //a partir o byte 16 copia 8 bytes
        direcao:= Copy(buffer_acumulador,47,6);
        velocidade:= Copy(buffer_acumulador,53,7);
        latitude:= Copy(buffer_acumulador,70,7);
        longitude:= Copy(buffer_acumulador,77,8);

        //variaveis exclusivas clbi
        ascrat:= Copy(buffer_acumulador,6,10);
        pressure:= Copy(buffer_acumulador,16,10);
        temp:= Copy(buffer_acumulador,36,9);
        u:= Copy(buffer_acumulador,58,6);
        v:= Copy(buffer_acumulador,64,6);
        TD:= Copy(buffer_acumulador,85,8);


        //removento os espaço das string capturadas de tempo, altitude, direcao e velocidade
        //tempo:= StringReplace(tempo, ' ', '', [rfReplaceAll, rfIgnoreCase]);
        altitude:= StringReplace(altitude, ' ', '', [rfReplaceAll, rfIgnoreCase]);
        direcao:= StringReplace(direcao, ' ', '', [rfReplaceAll, rfIgnoreCase]);
        velocidade:= StringReplace(velocidade, ' ', '', [rfReplaceAll, rfIgnoreCase]);
        latitude:= StringReplace(latitude, ' ', '', [rfReplaceAll, rfIgnoreCase]);
        longitude:= StringReplace(longitude, ' ', '', [rfReplaceAll, rfIgnoreCase]);

        //variaveis exclusivas clbi
        ascrat:= StringReplace(ascrat, ' ', '', [rfReplaceAll, rfIgnoreCase]);
        pressure:= StringReplace(pressure, ' ', '', [rfReplaceAll, rfIgnoreCase]);
        temp:= StringReplace(temp, ' ', '', [rfReplaceAll, rfIgnoreCase]);
        u:= StringReplace(u, ' ', '', [rfReplaceAll, rfIgnoreCase]);
        v:= StringReplace(v, ' ', '', [rfReplaceAll, rfIgnoreCase]);
        TD:= StringReplace(TD, ' ', '', [rfReplaceAll, rfIgnoreCase]);


        //como o TD fica no final da tranmissao, e as vezes tá deslocado, as vezes acaba pegano o 0d  (char(13))
        //ou mesmo o 0a (char(10) por isso o 0d e 0a são removidos para evitar problemas nos calculos
        delete (TD,pos(char(13),TD),1);
        delete (TD,pos(char(10),TD),1);


        //a versao antiga do digicora nao enviava na serial o (-) na latitude e longitude,
        //mas a digicora nova envia o (-),por isso
        //esse (-) é removido na retransmissao para o Potengi
        latitude:= StringReplace(latitude, '-', '', [rfReplaceAll, rfIgnoreCase]);
        longitude:= StringReplace(longitude, '-', '', [rfReplaceAll, rfIgnoreCase]);


        label29.caption:= tempo;
        label6.caption:= altitude;
        label7.Caption:= direcao;
        label8.caption:= velocidade;
        label34.caption:= latitude;
        label35.caption:= longitude;


{
*******************************************************************************************
String filtranda de exibição na tela dos dados que são relevantes para retransmissão
*******************************************************************************************
}

        string_filtrada:= ''; //iniciando limpa a string_filtrada
        string_filtrada:=tempo; //iniciando a string_filtrada


        //montando a string filtrada de altitude
        //****************************************
        tamanho:= length(altitude);  //conta o numero de carateres da string
        num_espacos:= 8-tamanho; //numero de vezes que vai gerar espaços
                               //o 5 é o espaço que tem para enviar a informacao de altitude na string que vai para o Potengi

        //acrescentando a string_filtrada o numero de espaços necessários
        for contador:= 1 to num_espacos do
          begin
            string_filtrada:= string_filtrada+' ';
          end;
        //atualizando string_filtrada
        string_filtrada:= string_filtrada + altitude;


        //montando a string filtrada de direcao
        //****************************************
        tamanho:= length(direcao);  //conta o numero de carateres da string
        num_espacos:= 9-tamanho; //numero de vezes que vai gerar espaços

        //acrescentando a string_filtrada o numero de espaços necessários
        for contador:= 1 to num_espacos do
          begin
            string_filtrada:= string_filtrada+' ';
          end;
        //atualizando string_filtrada
        string_filtrada:= string_filtrada + direcao;


        //montando a string filtrada de velocidade
        //****************************************
        tamanho:= length(velocidade);  //conta o numero de carateres da string
        num_espacos:= 7-tamanho; //numero de vezes que vai gerar espaços

        //acrescentando a string_filtrada o numero de espaços necessários
        for contador:= 1 to num_espacos do
          begin
            string_filtrada:= string_filtrada+' ';
          end;
        //atualizando string_filtrada
        string_filtrada:= string_filtrada + velocidade;


        //montando a string filtrada de latitude
        //****************************************
        tamanho:= length(latitude);  //conta o numero de carateres da string
        num_espacos:= 7-tamanho; //numero de vezes que vai gerar espaços

        //acrescentando a string_filtrada o numero de espaços necessários
        for contador:= 1 to num_espacos do
          begin
            string_filtrada:= string_filtrada+' ';
          end;
        //atualizando string_filtrada
        string_filtrada:= string_filtrada + latitude;



        //montando a string filtrada de longitude
        //****************************************
        tamanho:= length(longitude);  //conta o numero de carateres da string
        num_espacos:= 9-tamanho; //numero de vezes que vai gerar espaços

        //acrescentando a string_filtrada o numero de espaços necessários
        for contador:= 1 to num_espacos do
          begin
            string_filtrada:= string_filtrada+' ';
          end;
        //atualizando string_filtrada
        string_filtrada:= string_filtrada + longitude;


        Memo2.Lines.Add(string_filtrada);
        //Memo2.Text := Memo2.Text + string_filtrada;
        //SendMessage(Memo2.Handle, WM_VSCROLL, SB_BOTTOM, 0); //manter o foco no final do memo




{
*******************************************************************************************
String filtranda para retransmissão na serial
*******************************************************************************************
}
        string_filtrada_serial:= ''; //iniciando limpa a string_filtrada_serial
        string_filtrada_serial:= tempo; //iniciando a string_filtrada_serial




        //montando a string filtrada retransmissão na serial de AscRat
        //****************************************************************************
        tamanho:= length(ascrat);  //conta o numero de carateres da string
        num_espacos:= 9-tamanho; //numero de vezes que vai gerar espaços
                               //o 9 é o espaço que tem para enviar a informacao de AscRate na string que vai para o Potengi

        //acrescentando a string_filtrada_serial o numero de espaços necessários
        for contador:= 1 to num_espacos do
          begin
            string_filtrada_serial:= string_filtrada_serial+' ';
          end;
        //atualizando string_filtrada
        string_filtrada_serial:= string_filtrada_serial + ascrat;



        //montando a string filtrada retransmissão na serial de Pressure   (valor fixo)
        //****************************************************************************
        tamanho:= length(pressure);  //conta o numero de carateres da string
        num_espacos:= 10-tamanho; //numero de vezes que vai gerar espaços
                               //o 10 é o espaço que tem para enviar a informacao de pressure na string que vai para o Potengi

        //acrescentando a string_filtrada_serial o numero de espaços necessários
        for contador:= 1 to num_espacos do
          begin
            string_filtrada_serial:= string_filtrada_serial+' ';
          end;
        //atualizando string_filtrada
        string_filtrada_serial:= string_filtrada_serial + pressure;



        //montando a string filtrada retransmissão na serial de hgt_msl (altitude)
        //****************************************
        tamanho:= length(altitude);  //conta o numero de carateres da string
        num_espacos:= 10-tamanho; //numero de vezes que vai gerar espaços
                               //o 5 é o espaço que tem para enviar a informacao de hgt_msl na string que vai para o Potengi

        //acrescentando a string_filtrada o numero de espaços necessários
        for contador:= 1 to num_espacos do
          begin
            string_filtrada_serial:= string_filtrada_serial+' ';
          end;
        //atualizando string_filtrada
        string_filtrada_serial:= string_filtrada_serial + altitude;



        //montando a string filtrada retransmissão na serial de Temp
        //****************************************************************************
        tamanho:= length(temp);  //conta o numero de carateres da string
        num_espacos:= 10-tamanho; //numero de vezes que vai gerar espaços
                               //o 10 é o espaço que tem para enviar a informacao de Temp na string que vai para o Potengi

        //acrescentando a string_filtrada_serial o numero de espaços necessários
        for contador:= 1 to num_espacos do
          begin
            string_filtrada_serial:= string_filtrada_serial+' ';
          end;
        //atualizando string_filtrada
        string_filtrada_serial:= string_filtrada_serial + temp;


        //montando a string filtrada retransmissão na serial de Dir (direção)
        //**************************************************************************
        tamanho:= length(direcao);  //conta o numero de carateres da string
        num_espacos:= 9-tamanho; //numero de vezes que vai gerar espaços

        //acrescentando a string_filtrada o numero de espaços necessários
        for contador:= 1 to num_espacos do
          begin
            string_filtrada_serial:= string_filtrada_serial+' ';
          end;
        //atualizando string_filtrada
        string_filtrada_serial:= string_filtrada_serial + direcao;



        //montando a string filtrada retransmissão na serial de Speed (velocidade)
        //*************************************************************************
        tamanho:= length(velocidade);  //conta o numero de carateres da string
        num_espacos:= 9-tamanho; //numero de vezes que vai gerar espaços

        //acrescentando a string_filtrada o numero de espaços necessários
        for contador:= 1 to num_espacos do
          begin
            string_filtrada_serial:= string_filtrada_serial+' ';
          end;
        //atualizando string_filtrada
        string_filtrada_serial:= string_filtrada_serial + velocidade;




        //montando a string filtrada retransmissão na serial de RH -umidade relativa-  (valor fixo)
        //****************************************************************************
        tamanho:= length('75');  //conta o numero de carateres da string
        num_espacos:= 5-tamanho; //numero de vezes que vai gerar espaços
                               //o 10 é o espaço que tem para enviar a informacao de RH na string que vai para o Potengi

        //acrescentando a string_filtrada_serial o numero de espaços necessários
        for contador:= 1 to num_espacos do
          begin
            string_filtrada_serial:= string_filtrada_serial+' ';
          end;
        //atualizando string_filtrada
        string_filtrada_serial:= string_filtrada_serial + '75';




        //montando a string filtrada retransmissão na serial de 'u'
        //****************************************************************************
        tamanho:= length(u);  //conta o numero de carateres da string
        num_espacos:= 8-tamanho; //numero de vezes que vai gerar espaços
                               //o 8 é o espaço que tem para enviar a informacao de 'u' na string que vai para o Potengi

        //acrescentando a string_filtrada_serial o numero de espaços necessários
        for contador:= 1 to num_espacos do
          begin
            string_filtrada_serial:= string_filtrada_serial+' ';
          end;
        //atualizando string_filtrada
        string_filtrada_serial:= string_filtrada_serial + u;



        //montando a string filtrada retransmissão na serial de 'v'
        //****************************************************************************
        tamanho:= length(v);  //conta o numero de carateres da string
        num_espacos:= 8-tamanho; //numero de vezes que vai gerar espaços
                               //o 8 é o espaço que tem para enviar a informacao de 'u' na string que vai para o Potengi

        //acrescentando a string_filtrada_serial o numero de espaços necessários
        for contador:= 1 to num_espacos do
          begin
            string_filtrada_serial:= string_filtrada_serial+' ';
          end;
        //atualizando string_filtrada
        string_filtrada_serial:= string_filtrada_serial + v;





        //montando a string filtrada retransmissão na serial de Lat (latitude)
        //****************************************
        tamanho:= length(latitude);  //conta o numero de carateres da string
        num_espacos:= 8-tamanho; //numero de vezes que vai gerar espaços

        //acrescentando a string_filtrada o numero de espaços necessários
        for contador:= 1 to num_espacos do
          begin
            string_filtrada_serial:= string_filtrada_serial+' ';
          end;
        //atualizando string_filtrada
        string_filtrada_serial:= string_filtrada_serial + latitude;



        //montando a string filtrada retransmissão na serial de long (longitude)
        //****************************************
        tamanho:= length(longitude);  //conta o numero de carateres da string
        num_espacos:= 8-tamanho; //numero de vezes que vai gerar espaços

        //acrescentando a string_filtrada o numero de espaços necessários
        for contador:= 1 to num_espacos do
          begin
            string_filtrada_serial:= string_filtrada_serial+' ';
          end;
        //atualizando string_filtrada
        string_filtrada_serial:= string_filtrada_serial + longitude;



        //montando a string filtrada retransmissão na serial de TD  (converter de Kelvin para Celsius
        //****************************************************************************

        //o valor TD transmitido pela digicora é decrementado de 273,15
        //para converter de kelvin para celsius
        //a função float só aceita ',' no lugar de '.'
        TD:= StringReplace(TD,'.',',',[rfReplaceAll, rfIgnoreCase]);

        //TD_celcius:= strtofloat(StringReplace(TD,'.',',',[rfReplaceAll, rfIgnoreCase]));
        TD_celcius:= strtofloat(TD);
        TD_celcius:= TD_celcius - 273.15;

        //arredondamenteo simples...as vezes ficava xx.xx00000000001
        TD_celcius:= SimpleRoundTo(TD_celcius, -2);

        TD:= floattostr(TD_celcius);
        TD:=  StringReplace(TD,',','.',[rfReplaceAll, rfIgnoreCase]);

        tamanho:= length(TD);  //conta o numero de carateres da string
        num_espacos:= 9-tamanho; //numero de vezes que vai gerar espaços
                               //o 8 é o espaço que tem para enviar a informacao de 'u' na string que vai para o Potengi

        //acrescentando a string_filtrada_serial o numero de espaços necessários
        for contador:= 1 to num_espacos do
          begin
            string_filtrada_serial:= string_filtrada_serial+' ';
          end;
        //atualizando string_filtrada
        string_filtrada_serial:= string_filtrada_serial + TD;





        //enviando a string filtrada somente se a porta serial com o Potengi estiver conectada
        //e o checkbox estiver marcado como ON
        if (comport2.Connected) and (CheckBox1.checked= true) then
          begin
              label25.caption:= string_filtrada_serial;
              comport2.WriteStr(char(0)+string_filtrada_serial+char(13)+char(10)); //escrevendo na serial que vai para o Potengi

          end;
      end;








    //************************************
    //código da gravacao em arquivo .trn
    //************************************
    if (iniciado_gravacao=true) then //só começa a gravar se tiver sido iniciado a gravacao
      begin

        try
          AssignFile(arq, 'ARQTMP.TRN'); //associa a variavel 'arq' a o arquivo fisico 'ARQTMP.TRN'
          Append(arq); //abre um arquivo texto 'ARQTMP.TRN' existente para extendê-lo
          {
          para gerar um .trn igual o alcmet antigo é necessário fazer
          um tratamento na string que vem da serial
          da serial vem primeiro 0a depois 0d
          mas isso faz com que o .trn nao seja vizualizado no notepad com
          quebra de linha
          jah no notepad++ é vizualizado como duas quebras de linha

          o .trn que o alcmet antigo grava no final da linha de dados
          primeiro 0d e depois 0a e isso permite a vizualizacao
          da quebra de linnho no notepad
          }

          dados_gravar:= buffer_acumulador;

          //removendo os 0a de dados_gravar
          while pos(char(10),dados_gravar) > 0 do
          begin
            //deletando o caractere NULL
            delete (dados_gravar,pos(char(10),dados_gravar),1);
          end;

          //removendo os 0d de dados_gravar
          while pos(char(13),dados_gravar) > 0 do
          begin
            //deletando o caractere NULL
            delete (dados_gravar,pos(char(13),dados_gravar),1);
          end;

          //acrescentando 0d e 0a no final de dados_gravar
          dados_gravar:= dados_gravar+char(13)+char(10);

          //gravacao no .trn
          Write(arq, dados_gravar);

          //gravacao no .trn de forma integral e sem alteracao da serial
          //Write(arq, RxComport); //gravando com 'write' o arquivo 'ARQTMP.TRN' tem uma copia exata dos dados q chegaram da serial

          CloseFile(arq); // fecha o arquivo texto 'ARQTMP.TRN'
        except
        end;
      end;
    buffer_acumulador:=''; //resetando o buffer acumulador


//a partir de uns 1500 registros no memo observei problemas
//por isso a cada 200 inserções é feita a limpeza dos memos

if (Memo1.Lines.Count>=200) then
  begin
  memo1.clear;
  memo2.clear
  end;

{
Memo1.Lines.Add(RxComport_notnull);
//Memo1.Text := Memo1.Text + Rxcomport_notnull;
SendMessage(Memo1.Handle, WM_VSCROLL, SB_BOTTOM, 0); //manter o foco no final do memo
}


{
a principio cada linha de dados tem um total de 62 bytes
sem contar com os caracteres de controle de carro
O Alcmet recebe da Digicora as linhas:

Started at:      31 05 19 23 30 GMT

   Time AscRate Hgt/MSL Pressure   Temp  RH   dEWP  Dir Speed

      s     m/s       m      hPa   degC   %   degC  deg   m/s

  00000     0.0      49   1005.9   26.4  90   24.6   90   1.0
  00002    10.0      69   1003.6   26.5  87   24.2   83   2.8
  00004     5.5      80   1002.4   26.6  87   24.2   76   4.4
  00006     5.0      90   1001.3   26.9  86   24.3   71   5.9
na saida do Alcmet é retransmitido para o Guará somente:

   49  90  1.0
   69  83  2.8
   80  76  4.4
   90  71  5.9
  101  66  7.1
  112  63  7.8
   |    |    |
   |    |    |
   |    |    +--> velocidade do vento
   |    +-------> direção do vento
   +------------> altitude
}


//tentando detectar a linha com o data e hora da leitura da digicora no cabeçalho
//a principio sao 38 bytes a linha de cabeçalho de interesse
if (RxCount=38) then
  begin
    sugestao_nome_arquivo:= RxComport; //copiando da leitura da serial
    sugestao_nome_arquivo:= Copy(sugestao_nome_arquivo,18,14); //pegando somente a informacao de data e hora
    sugestao_nome_arquivo:= StringReplace(sugestao_nome_arquivo, ' ', '', [rfReplaceAll, rfIgnoreCase]); //removendo espaços
    sugestao_nome_arquivo := sugestao_nome_arquivo+'.TRN';
  end;

end;

end.
