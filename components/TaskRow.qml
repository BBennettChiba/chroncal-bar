import QtQuick
import qs.Commons
import qs.Ui
import "../Model.js" as Model

Item {
  id: root

  property var bar: null
  property var taskData: ({})
  property string nowIso: ""

  // ponytail: read-only for now — no complete/edit action from the panel.
  // Todos are CLI-managed (`chroncal todo ...`); add a click-to-complete
  // action here if that friction turns out to matter in practice.

  readonly property color foreground: bar ? bar.foreground : Color.foreground
  readonly property string dueLabel: Model.taskDateLabel(root.taskData, root.nowIso ? new Date(root.nowIso) : new Date())

  implicitHeight: Style.space(36)

  Rectangle {
    width: Style.space(3)
    anchors.left: parent.left
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    radius: width / 2
    color: root.taskData.calendar_color || "#888888"
  }

  Text {
    id: summaryText
    anchors.left: parent.left
    anchors.leftMargin: Style.space(12)
    anchors.right: dueBadge.visible ? dueBadge.left : parent.right
    anchors.rightMargin: Style.space(8)
    anchors.verticalCenter: parent.verticalCenter
    text: root.taskData.summary || "Untitled"
    textFormat: Text.PlainText
    color: root.foreground
    font.family: root.bar ? root.bar.fontFamily : Style.font.family
    font.pixelSize: Style.font.body
    elide: Text.ElideRight
  }

  Text {
    id: dueBadge
    visible: root.dueLabel !== ""
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    text: root.dueLabel
    textFormat: Text.PlainText
    color: Util.alpha(root.foreground, 0.62)
    font.family: root.bar ? root.bar.fontFamily : Style.font.family
    font.pixelSize: Style.font.caption
  }
}
