object FrmCanvasResize: TFrmCanvasResize
  Left = 103
  Top = 202
  BorderIcons = [biSystemMenu]
  Caption = 'Canvas Resize'
  ClientHeight = 715
  ClientWidth = 1267
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
    1267
    715)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 277
    Top = 628
    Width = 25
    Height = 13
    Alignment = taRightJustify
    Anchors = [akLeft, akBottom]
    Caption = 'Top: '
    ExplicitTop = 595
  end
  object Label2: TLabel
    Left = 163
    Top = 637
    Width = 21
    Height = 13
    Alignment = taRightJustify
    Anchors = [akRight, akBottom]
    Caption = 'Left:'
  end
  object Label3: TLabel
    Left = 263
    Top = 656
    Width = 39
    Height = 13
    Alignment = taRightJustify
    Anchors = [akLeft, akBottom]
    Caption = 'Bottom: '
  end
  object Label4: TLabel
    Left = 401
    Top = 637
    Width = 31
    Height = 13
    Alignment = taRightJustify
    Anchors = [akRight, akBottom]
    Caption = 'Right: '
  end
  object Bevel1: TBevel
    Left = 0
    Top = 675
    Width = 1263
    Height = 10
    Anchors = [akLeft, akRight, akBottom]
    Shape = bsBottomLine
    ExplicitTop = 290
    ExplicitWidth = 329
  end
  object PaintAreaPanel: TPanel
    Left = 0
    Top = 0
    Width = 1264
    Height = 622
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelInner = bvLowered
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitWidth = 330
    ExplicitHeight = 237
    DesignSize = (
      1264
      622)
    object Image1: TImage
      Left = 1
      Top = 1
      Width = 1262
      Height = 620
      Anchors = [akLeft, akTop, akRight, akBottom]
      ExplicitWidth = 329
      ExplicitHeight = 233
    end
  end
  object SpinT: TSpinEdit
    Left = 308
    Top = 628
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
    Left = 308
    Top = 656
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
    Left = 190
    Top = 634
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
    Left = 454
    Top = 634
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
    Left = 1102
    Top = 690
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    TabOrder = 5
    OnClick = BtOKClick
    ExplicitLeft = 168
    ExplicitTop = 305
  end
  object BtCancel: TButton
    Left = 1185
    Top = 690
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    TabOrder = 6
    OnClick = BtCancelClick
    ExplicitLeft = 251
    ExplicitTop = 305
  end
  object XPManifest: TXPManifest
    Left = 56
    Top = 304
  end
end
