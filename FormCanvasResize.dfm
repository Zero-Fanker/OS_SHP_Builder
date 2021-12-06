object FrmCanvasResize: TFrmCanvasResize
  Left = 103
  Top = 202
  BorderIcons = [biSystemMenu]
  Caption = 'Canvas Resize'
  ClientHeight = 330
  ClientWidth = 333
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnResize = FormResize
  OnShow = FormShow
  DesignSize = (
    333
    330)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 45
    Top = 248
    Width = 25
    Height = 13
    Alignment = taRightJustify
    Anchors = [akLeft, akBottom]
    Caption = 'Top: '
  end
  object Label2: TLabel
    Left = 208
    Top = 248
    Width = 21
    Height = 13
    Alignment = taRightJustify
    Anchors = [akRight, akBottom]
    Caption = 'Left:'
  end
  object Label3: TLabel
    Left = 29
    Top = 272
    Width = 39
    Height = 13
    Alignment = taRightJustify
    Anchors = [akLeft, akBottom]
    Caption = 'Bottom: '
  end
  object Label4: TLabel
    Left = 196
    Top = 272
    Width = 31
    Height = 13
    Alignment = taRightJustify
    Anchors = [akRight, akBottom]
    Caption = 'Right: '
  end
  object Bevel1: TBevel
    Left = 0
    Top = 290
    Width = 329
    Height = 10
    Anchors = [akLeft, akRight, akBottom]
    Shape = bsBottomLine
  end
  object PaintAreaPanel: TPanel
    Left = 0
    Top = 0
    Width = 330
    Height = 237
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelInner = bvLowered
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      330
      237)
    object Image1: TImage
      Left = 1
      Top = 1
      Width = 328
      Height = 235
      Anchors = [akLeft, akTop, akRight, akBottom]
      ExplicitWidth = 329
      ExplicitHeight = 233
    end
  end
  object SpinT: TSpinEdit
    Left = 80
    Top = 242
    Width = 57
    Height = 22
    Anchors = [akLeft, akBottom]
    MaxValue = 10000
    MinValue = -10000
    TabOrder = 1
    Value = 0
    OnChange = SpinTChange
    OnKeyDown = FormKeyDown
  end
  object SpinB: TSpinEdit
    Left = 80
    Top = 266
    Width = 57
    Height = 22
    Anchors = [akLeft, akBottom]
    MaxValue = 10000
    MinValue = -10000
    TabOrder = 2
    Value = 0
    OnChange = SpinBChange
    OnKeyDown = FormKeyDown
  end
  object SpinL: TSpinEdit
    Left = 240
    Top = 242
    Width = 57
    Height = 22
    Anchors = [akRight, akBottom]
    MaxValue = 10000
    MinValue = -10000
    TabOrder = 3
    Value = 0
    OnChange = SpinLChange
    OnKeyDown = FormKeyDown
  end
  object SpinR: TSpinEdit
    Left = 240
    Top = 266
    Width = 57
    Height = 22
    Anchors = [akRight, akBottom]
    MaxValue = 10000
    MinValue = -10000
    TabOrder = 4
    Value = 0
    OnChange = SpinRChange
    OnKeyDown = FormKeyDown
  end
  object BtOK: TButton
    Left = 168
    Top = 305
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    TabOrder = 5
    OnClick = BtOKClick
  end
  object BtCancel: TButton
    Left = 251
    Top = 305
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    TabOrder = 6
    OnClick = BtCancelClick
  end
  object XPManifest: TXPManifest
    Left = 56
    Top = 304
  end
end
