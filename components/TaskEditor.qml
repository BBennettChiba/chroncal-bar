pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls as QQC
import qs.Commons
import qs.Ui
import "../Model.js" as Model

// ponytail: edit-only (no create, no recurrence editing) — matches the
// fields chroncal-bar-tasks already surfaces. Widen alongside Model.js's
// taskMutationArgs if that turns out to be too limiting in practice.
Flickable {
  id: root

  property var bar: null
  property var taskData: null
  property bool busy: false
  property string externalError: ""

  property string summaryValue: ""
  property string dueValue: ""
  property string startValue: ""
  property string statusValue: "NEEDS-ACTION"
  property int priorityValue: 0
  property string descriptionValue: ""
  property bool submitAttempted: false

  readonly property color foreground: bar ? bar.foreground : Color.foreground
  readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family
  readonly property var validationErrors: Model.validateTaskForm(values())

  signal canceled()
  signal submitted(var values)

  function values() {
    return {
      summary: summaryValue,
      due: dueValue,
      start: startValue,
      status: statusValue,
      priority: priorityValue,
      description: descriptionValue
    }
  }

  function initialize() {
    var initial = Model.taskEditorValues(taskData)
    summaryValue = initial.summary
    dueValue = initial.due
    startValue = initial.start
    statusValue = initial.status
    priorityValue = initial.priority
    descriptionValue = initial.description
    submitAttempted = false
    Qt.callLater(function() { summaryField.forceActiveFocus() })
  }

  function closePickers() {
    dueDatePicker.close()
    startDatePicker.close()
  }

  function submit() {
    submitAttempted = true
    if (validationErrors.length === 0 && !busy) submitted(values())
  }

  onVisibleChanged: {
    if (visible) initialize()
    else closePickers()
  }

  Keys.priority: Keys.BeforeItem
  Keys.onPressed: function(event) {
    if (event.key === Qt.Key_Escape) {
      if (dueDatePicker.opened) dueDatePicker.close()
      else if (startDatePicker.opened) startDatePicker.close()
      else if (statusDropdown.popupOpen) statusDropdown.close()
      else root.canceled()
      event.accepted = true
    } else if ((event.modifiers & Qt.ControlModifier) && (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_S)) {
      dueDatePicker.commitIfOpen()
      startDatePicker.commitIfOpen()
      root.submit()
      event.accepted = true
    }
  }

  contentWidth: width
  contentHeight: form.implicitHeight
  clip: true
  boundsBehavior: Flickable.StopAtBounds
  flickableDirection: Flickable.VerticalFlick
  QQC.ScrollBar.vertical: QQC.ScrollBar { policy: QQC.ScrollBar.AsNeeded }

  component FieldLabel: Text {
    color: Util.alpha(root.foreground, 0.56)
    font.family: root.fontFamily
    font.pixelSize: Style.font.caption
    font.bold: true
    font.letterSpacing: 0.8
  }

  component FormField: QQC.TextField {
    color: root.foreground
    placeholderTextColor: Util.alpha(root.foreground, 0.42)
    font.family: root.fontFamily
    font.pixelSize: Style.font.body
    leftPadding: Style.space(10)
    rightPadding: Style.space(10)
    selectByMouse: true
    background: Rectangle {
      radius: Style.cornerRadius
      color: Util.alpha(root.foreground, parent.activeFocus ? 0.10 : 0.06)
      border.width: 1
      border.color: Util.alpha(root.foreground, parent.activeFocus ? 0.28 : 0.12)
    }
  }

  component FormButton: Button {
    foreground: root.foreground
    fontFamily: root.fontFamily
    bordered: true
    focusable: true
    enabled: !root.busy
    opacity: enabled ? 1 : 0.55
  }

  component ClearButton: FormButton {
    text: "Clear"
    fontSize: Style.font.bodySmall
    horizontalPadding: Style.space(8)
    verticalPadding: Style.space(3)
  }

  Column {
    id: form
    width: root.width
    spacing: Style.space(8)

    FieldLabel { text: "SUMMARY" }
    FormField {
      id: summaryField
      width: parent.width
      text: root.summaryValue
      placeholderText: "Task summary"
      onTextEdited: root.summaryValue = text
      onAccepted: root.submit()
    }

    FieldLabel { text: "DUE DATE" }
    Row {
      width: parent.width
      spacing: Style.space(8)

      DatePicker {
        id: dueDatePicker
        width: parent.width - clearDueButton.width - Style.space(8)
        value: root.dueValue
        foreground: root.foreground
        fontFamily: root.fontFamily
        onChanged: function(value) { root.dueValue = value }
      }

      ClearButton {
        id: clearDueButton
        enabled: !root.busy && root.dueValue !== ""
        onClicked: root.dueValue = ""
      }
    }

    FieldLabel { text: "START DATE" }
    Row {
      width: parent.width
      spacing: Style.space(8)

      DatePicker {
        id: startDatePicker
        width: parent.width - clearStartButton.width - Style.space(8)
        value: root.startValue
        foreground: root.foreground
        fontFamily: root.fontFamily
        onChanged: function(value) { root.startValue = value }
      }

      ClearButton {
        id: clearStartButton
        enabled: !root.busy && root.startValue !== ""
        onClicked: root.startValue = ""
      }
    }

    FieldLabel { text: "STATUS" }
    Dropdown {
      id: statusDropdown
      width: parent.width
      showLabel: false
      options: Model.taskStatusOptions()
      enabled: !root.busy
      foreground: root.foreground
      fontFamily: root.fontFamily
      onChanged: function(value) { root.statusValue = value }
    }

    Binding {
      target: statusDropdown
      property: "value"
      value: root.statusValue
    }

    FieldLabel { text: "PRIORITY (0 = none, 1 = highest, 9 = lowest)" }
    NumberField {
      width: parent.width
      value: root.priorityValue
      from: 0
      to: 9
      stepSize: 1
      enabled: !root.busy
      foreground: root.foreground
      fontFamily: root.fontFamily
      onModified: function(value) { root.priorityValue = value }
    }

    FieldLabel { text: "NOTES" }
    QQC.TextArea {
      width: parent.width
      height: Style.space(48)
      text: root.descriptionValue
      placeholderText: "Optional description"
      color: root.foreground
      placeholderTextColor: Util.alpha(root.foreground, 0.42)
      font.family: root.fontFamily
      font.pixelSize: Style.font.bodySmall
      wrapMode: QQC.TextArea.Wrap
      selectByMouse: true
      padding: Style.space(10)
      onTextChanged: root.descriptionValue = text
      background: Rectangle {
        radius: Style.cornerRadius
        color: Util.alpha(root.foreground, parent.activeFocus ? 0.10 : 0.06)
        border.width: 1
        border.color: Util.alpha(root.foreground, parent.activeFocus ? 0.28 : 0.12)
      }
    }

    Text {
      visible: (root.submitAttempted && root.validationErrors.length > 0) || root.externalError !== ""
      width: parent.width
      text: root.externalError !== "" ? root.externalError : root.validationErrors.join("\n")
      textFormat: Text.PlainText
      color: Color.urgent
      font.family: root.fontFamily
      font.pixelSize: Style.font.caption
      wrapMode: Text.WordWrap
    }

    Row {
      anchors.right: parent.right
      spacing: Style.space(8)

      FormButton {
        text: "Cancel"
        onClicked: root.canceled()
      }

      FormButton {
        text: root.busy ? "Saving…" : "Save"
        background: Util.alpha(root.foreground, 0.08)
        onClicked: root.submit()
      }
    }
  }
}
