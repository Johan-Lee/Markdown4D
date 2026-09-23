unit Markdown4D.Editor.ContextMenu;

{$SCOPEDENUMS ON}

// What the editor's right-click menu offers and which entries are live, decided
// once for every framework. Hosts turn this list into their own menu widget and
// run the clipboard entries with their own clipboard.

interface

uses
  Markdown4D.Editor.Model;

type
  TEditorContextCommand = (Undo, Redo, Cut, Copy, Paste, DeleteSelection, SelectAll);

  TEditorContextItem = record
    Command: TEditorContextCommand;
    Caption: string;
    Enabled: Boolean;
    // A separator is drawn above this item when the host builds the menu.
    StartsGroup: Boolean;
    class function Create(const Command: TEditorContextCommand; const Caption: string;
      const Enabled, StartsGroup: Boolean): TEditorContextItem; static;
  end;

  TMarkdownEditorContextMenu = record
    class function Build(const Model: TMarkdownEditorModel; const ClipboardHasText: Boolean;
      const ReadOnly: Boolean = False): TArray<TEditorContextItem>; static; // [09.23.2026] Changed
    // Runs the entries that only touch the text. Clipboard entries return False
    // because they need the host's clipboard.
    class function Execute(const Model: TMarkdownEditorModel; const Command: TEditorContextCommand;
      const ReadOnly: Boolean = False): Boolean; static; // [09.23.2026] Changed
  end;

implementation

const
  UndoCaption = 'Undo';
  RedoCaption = 'Redo';
  CutCaption = 'Cut';
  CopyCaption = 'Copy';
  PasteCaption = 'Paste';
  DeleteCaption = 'Delete';
  SelectAllCaption = 'Select All';

class function TEditorContextItem.Create(const Command: TEditorContextCommand; const Caption: string;
  const Enabled, StartsGroup: Boolean): TEditorContextItem;
begin
  Result.Command := Command;
  Result.Caption := Caption;
  Result.Enabled := Enabled;
  Result.StartsGroup := StartsGroup;
end;

class function TMarkdownEditorContextMenu.Build(const Model: TMarkdownEditorModel;
  const ClipboardHasText: Boolean; const ReadOnly: Boolean = False): TArray<TEditorContextItem>; // [09.23.2026] Changed
begin
  const HasSelection = Model.HasSelection;
  const HasText = Length(Model.Text) > 0;

  Result := [
    TEditorContextItem.Create(TEditorContextCommand.Undo, UndoCaption, Model.CanUndo and not ReadOnly, False), // [09.23.2026] Changed
    TEditorContextItem.Create(TEditorContextCommand.Redo, RedoCaption, Model.CanRedo and not ReadOnly, False), // [09.23.2026] Changed
    TEditorContextItem.Create(TEditorContextCommand.Cut, CutCaption, HasSelection and not ReadOnly, True),// [09.23.2026] Changed
    TEditorContextItem.Create(TEditorContextCommand.Copy, CopyCaption, HasSelection, False),
    TEditorContextItem.Create(TEditorContextCommand.Paste, PasteCaption, ClipboardHasText and not ReadOnly, False), // [09.23.2026] Changed
    TEditorContextItem.Create(TEditorContextCommand.DeleteSelection, DeleteCaption, HasSelection and not ReadOnly, False), // [09.23.2026] Changed
    TEditorContextItem.Create(TEditorContextCommand.SelectAll, SelectAllCaption, HasText, True)
  ];
end;

class function TMarkdownEditorContextMenu.Execute(const Model: TMarkdownEditorModel;
  const Command: TEditorContextCommand; const ReadOnly: Boolean = False): Boolean; // [09.23.2026] Changed
begin
  Result := True;

  if ReadOnly and (Command in [TEditorContextCommand.Undo, TEditorContextCommand.Redo,
    TEditorContextCommand.DeleteSelection]) then
    Exit; // [09.23.2026] Added

  case Command of
    TEditorContextCommand.Undo:
      Model.Undo;
    TEditorContextCommand.Redo:
      Model.Redo;
    TEditorContextCommand.DeleteSelection:
      Model.DeleteForward;
    TEditorContextCommand.SelectAll:
      Model.SelectAll;
  else
    Result := False;
  end;
end;

end.
