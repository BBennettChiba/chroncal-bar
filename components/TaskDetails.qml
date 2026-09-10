pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import qs.Commons
import qs.Ui
import "../Model.js" as Model

Item {
  id: root

  property var bar: null
  property var taskData: ({})
  property string nowIso: ""
  property string actionStatus: ""
  property bool busy: false

  signal editRequested()
  signal deleteRequested()
  signal completeRequested()

  readonly property color foreground: bar ? bar.foreground : Color.foreground
  readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family
  readonly property bool canEdit: Model.canEditTask(taskData)
  readonly property bool canDelete: Model.canDeleteTask(taskData)
  readonly property string dateLabel: Model.taskDateLabel(taskData, nowIso ? new Date(nowIso) : new Date())
  readonly property string statusLabel: {
    var options = Model.taskStatusOptions();
    for (var index = 0; index < options.length; index += 1)
      if (options[index].value === root.taskData.status) return options[index].label;
    return String(root.taskData.status || "Not started");
  }

  onTaskDataChanged: detailsFlick.contentY = 0

  Flickable {
    id: detailsFlick
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: actionsFooter.top
    anchors.bottomMargin: Style.space(12)
    contentWidth: width
    contentHeight: detailsColumn.implicitHeight
    clip: true
    boundsBehavior: Flickable.StopAtBounds
    flickableDirection: Flickable.VerticalFlick
    interactive: contentHeight > height
    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

    Column {
      id: detailsColumn
      width: detailsFlick.width
      spacing: Style.space(12)

      Text {
        width: parent.width
        text: root.taskData.summary || "Untitled"
        textFormat: Text.PlainText
        color: root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.title
        font.bold: true
        wrapMode: Text.Wrap
      }

      Rectangle {
        width: parent.width
        implicitHeight: taskSummary.implicitHeight + Style.space(20)
        radius: Style.cornerRadius
        color: Util.alpha(root.foreground, 0.06)

        Rectangle {
          width: Style.space(3)
          anchors.left: parent.left
          anchors.top: parent.top
          anchors.bottom: parent.bottom
          radius: width / 2
          color: root.taskData.calendar_color || "#888888"
        }

        Column {
          id: taskSummary
          anchors.left: parent.left
          anchors.leftMargin: Style.space(14)
          anchors.right: parent.right
          anchors.rightMargin: Style.space(12)
          anchors.verticalCenter: parent.verticalCenter
          spacing: Style.space(5)

          Text {
            visible: root.dateLabel !== ""
            width: parent.width
            text: root.dateLabel
            textFormat: Text.PlainText
            color: root.foreground
            font.family: root.fontFamily
            font.pixelSize: Style.font.body
            font.bold: true
            wrapMode: Text.Wrap
          }

          Text {
            width: parent.width
            text: root.statusLabel + (root.taskData.priority > 0 ? "  ·  Priority " + root.taskData.priority : "")
            textFormat: Text.PlainText
            color: Util.alpha(root.foreground, 0.82)
            font.family: root.fontFamily
            font.pixelSize: Style.font.body
            wrapMode: Text.Wrap
          }

          Text {
            width: parent.width
            text: root.taskData.calendar_name || "Calendar"
            textFormat: Text.PlainText
            color: Util.alpha(root.foreground, 0.62)
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
            elide: Text.ElideRight
          }
        }
      }

      Column {
        visible: String(root.taskData.description || "") !== ""
        width: parent.width
        spacing: Style.space(3)

        Text {
          text: "NOTES"
          color: Util.alpha(root.foreground, 0.52)
          font.family: root.fontFamily
          font.pixelSize: Style.font.caption
          font.bold: true
          font.letterSpacing: 1
        }

        Text {
          width: parent.width
          text: root.taskData.description || ""
          textFormat: Text.PlainText
          color: Util.alpha(root.foreground, 0.82)
          font.family: root.fontFamily
          font.pixelSize: Style.font.body
          wrapMode: Text.Wrap
        }
      }
    }
  }

  Column {
    id: actionsFooter
    z: 1
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    spacing: Style.space(12)

    Rectangle {
      width: parent.width
      height: 1
      color: Util.alpha(root.foreground, 0.12)
    }

    Item {
      width: parent.width
      height: Math.max(completeButton.height, actionIcons.height)

      Button {
        id: completeButton
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        text: "Mark complete"
        tooltipText: "Mark this task complete"
        bordered: true
        focusable: true
        enabled: !root.busy && root.canEdit
        opacity: enabled ? 1 : 0.55
        foreground: root.foreground
        fontFamily: root.fontFamily
        fontSize: Style.font.bodySmall
        horizontalPadding: Style.space(8)
        verticalPadding: Style.space(3)
        onClicked: root.completeRequested()
      }

      Text {
        visible: root.actionStatus !== ""
        text: root.actionStatus
        textFormat: Text.PlainText
        color: Util.alpha(root.foreground, 0.62)
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
        elide: Text.ElideRight
        wrapMode: Text.NoWrap
        maximumLineCount: 1
        verticalAlignment: Text.AlignVCenter
        anchors.left: completeButton.right
        anchors.leftMargin: Style.space(12)
        anchors.right: actionIcons.left
        anchors.rightMargin: Style.space(12)
        anchors.verticalCenter: parent.verticalCenter
      }

      Row {
        id: actionIcons
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: Style.space(18)

        PanelActionButton {
          iconText: "󰏫"
          tooltipText: "Edit task"
          foreground: root.foreground
          fontFamily: root.fontFamily
          focusable: true
          enabled: !root.busy && root.canEdit
          onClicked: root.editRequested()
        }

        PanelActionButton {
          iconText: "󰆴"
          tooltipText: "Delete task"
          foreground: root.foreground
          fontFamily: root.fontFamily
          focusable: true
          enabled: root.canDelete && !root.busy
          onClicked: root.deleteRequested()
        }
      }
    }
  }
}
