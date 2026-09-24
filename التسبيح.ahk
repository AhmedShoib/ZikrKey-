#Requires AutoHotkey v2.0
#SingleInstance Force

; ===== الإعدادات العامة =====
filePath    := A_ScriptDir "\تسبيح.txt"       ; ملف العداد
configPath  := A_ScriptDir "\إعدادات.txt"     ; ملف حفظ الحروف
settingsKey := "F1"                            ; مفتاح فتح نافذة الإعدادات

; القيم الافتراضية (تُستبدل من الملف إن وُجد)
incrementKey := "p"
saveExitKey  := "l"

; ===== قراءة / كتابة ملف الإعدادات =====
LoadConfig() {
    global incrementKey, saveExitKey, configPath
    if !FileExist(configPath)
        return
    content := FileRead(configPath, "UTF-8")
    for line in StrSplit(content, "`n", "`r") {
        if RegExMatch(line, "^\s*inc\s*=\s*(.+?)\s*$", &m)
            incrementKey := m[1]
        else if RegExMatch(line, "^\s*exit\s*=\s*(.+?)\s*$", &m)
            saveExitKey := m[1]
    }
}

SaveConfig() {
    global incrementKey, saveExitKey, configPath
    if FileExist(configPath)
        FileDelete(configPath)
    FileAppend("inc=" incrementKey "`nexit=" saveExitKey "`n", configPath, "UTF-8")
}

; ===== قراءة العداد =====
LoadCounter() {
    global filePath
    if !FileExist(filePath)
        return 0
    content := Trim(FileRead(filePath, "UTF-8"))
    if RegExMatch(content, "\d+", &m)
        return Integer(m[0])
    return 0
}

; ===== رسالة سريعة =====
ShowTip(text, ms := 800) {
    ToolTip(text)
    SetTimer(() => ToolTip(), -ms)
}

; ===== تسجيل الحروف (مع إلغاء القديمة) =====
registeredInc  := ""
registeredExit := ""

RegisterHotkeys() {
    global incrementKey, saveExitKey, registeredInc, registeredExit
    if (registeredInc != "")
        try Hotkey(registeredInc, "Off")
    if (registeredExit != "")
        try Hotkey(registeredExit, "Off")
    try Hotkey(incrementKey, IncrementHandler)
    try Hotkey(saveExitKey, SaveExitHandler)
    registeredInc  := incrementKey
    registeredExit := saveExitKey
}

; ===== دوال العداد =====
IncrementHandler(*) {
    global counter
    counter++
    ShowTip("العدد: " counter)
}

SaveExitHandler(*) {
    global counter, filePath
    if FileExist(filePath)
        FileDelete(filePath)
    FileAppend(counter, filePath, "UTF-8")
    ShowTip("تم الحفظ: " counter " — خروج", 1500)
    Sleep(1500)
    ExitApp()
}

; ===== نافذة الإعدادات =====
ShowSettings(*) {
    global incrementKey, saveExitKey, settingsKey
    g := Gui("+AlwaysOnTop", "إعدادات الحروف")
    g.SetFont("s11")
    g.Add("Text",, "حرف الزيادة:")
    incEdit := g.Add("Edit", "w120", incrementKey)
    g.Add("Text",, "حرف الحفظ والخروج:")
    exitEdit := g.Add("Edit", "w120", saveExitKey)
    g.Add("Text", "cGray", "مفتاح فتح الإعدادات: " settingsKey)
    btnSave   := g.Add("Button", "Default w100", "حفظ")
    btnCancel := g.Add("Button", "x+10 w100", "إلغاء")

    btnSave.OnEvent("Click",   (*) => ApplySettings(incEdit, exitEdit, g))
    btnCancel.OnEvent("Click", (*) => g.Destroy())
    g.Show()
}

ApplySettings(incEdit, exitEdit, g, *) {
    global incrementKey, saveExitKey, settingsKey
    inc := Trim(incEdit.Value)
    ext := Trim(exitEdit.Value)

    if (inc = "" || ext = "") {
        MsgBox("الرجاء إدخال حرفين صحيحين.", "خطأ", "Icon!")
        return
    }
    if (inc = ext) {
        MsgBox("لا يمكن أن يكون حرفا الزيادة والحفظ متطابقين.", "خطأ", "Icon!")
        return
    }
    if (inc = settingsKey || ext = settingsKey) {
        MsgBox("لا يمكن استخدام نفس مفتاح فتح الإعدادات.", "خطأ", "Icon!")
        return
    }

    incrementKey := inc
    saveExitKey  := ext
    SaveConfig()
    RegisterHotkeys()
    ShowTip("تم حفظ الإعدادات", 1500)
    g.Destroy()
}

; ===== التشغيل =====
LoadConfig()
if !FileExist(configPath)
    SaveConfig()          ; إنشاء ملف الإعدادات أول مرة

counter := LoadCounter()
RegisterHotkeys()
Hotkey(settingsKey, ShowSettings)

ShowTip("العدد الحالي: " counter "`n(اضغط " settingsKey " لفتح الإعدادات)", 2500)