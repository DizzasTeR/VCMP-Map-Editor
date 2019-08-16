function _print(msg, type = 0) {
    local msgTypes = [
        "[#FFFFFF]",
        "[#00FF00]",
        "[#FFFF00]",
        "[#FF0000]"
    ]
    Console.Print(msgTypes[0] + "[DEBUG] " + msg);
}

include("CEventHandler.nut");
include("editor.nut");

function Server::ServerData(stream) {
	invokeEvent("onServerData", stream);
}

function Script::ScriptLoad() {
    invokeEvent("onScriptLoad");
}

function Script::ScriptUnload() {
    invokeEvent("onScriptUnload");
}

function Script::ScriptProcess() {
    invokeEvent("onScriptProcess");
}

function Player::PlayerDeath(player) {
    invokeEvent("onClientDeath", player);
}

function Player::PlayerShoot(player, weapon, hitEntity, hitPosition) {
    invokeEvent("onClientShoot", player, weapon, hitEntity, hitPosition);
}

function GUI::ElementFocus(element) {
    invokeEvent("onGUIElementFocus", element);
}

function GUI::ElementBlur(element) {
    invokeEvent("onGUIElementBlur", element);
}

function GUI::ElementHoverOver(element) {
    invokeEvent("onGUIElementHover", element, true);
}

function GUI::ElementHoverOut(element) {
    invokeEvent("onGUIElementHover", element, false);
}

function GUI::ElementClick(element, mouseX, mouseY) {
    invokeEvent("onGUIElementClick", element, true, mouseX, mouseY);
}

function GUI::ElementRelease(element, mouseX, mouseY) {
    invokeEvent("onGUIElementClick", element, false, mouseX, mouseY);
}

function GUI::ElementDrag(element, mouseX, mouseY) {
    invokeEvent("onGUIElementDrag", element, mouseX, mouseY);
}

function GUI::CheckboxToggle(checkbox, checked) {
    invokeEvent("onGUICheckboxToggle", checkbox, checked);
}

function GUI::WindowClose(window) {
    invokeEvent("onGUIWindowClose", window);
}

function GUI::InputReturn(editbox) {
    invokeEvent("onGUIInputReturn", editbox);
}

function GUI::ListboxSelect(listbox, text) {
    invokeEvent("onGUIListboxSelect", listbox, text);
}

function GUI::ScrollbarScroll(scrollbar, position, change) {
    invokeEvent("onGUIScrollbarScroll", scrollbar, position, change);
}

function GUI::WindowResize(window, width, height) {
    invokeEvent("onGUIWindowResize", window, width, height);
}

function GUI::GameResize(width, height) {
    invokeEvent("onGUIResize", width, height);
}

function GUI::KeyPressed(key) {
    invokeEvent("onGUIKeyPressed", key);
}

function KeyBind::OnDown(key) {
    invokeEvent("onKeyPress", key, true);
}

function KeyBind::OnUp(key) {
    invokeEvent("onKeyPress", key, false);
}