#Requires AutoHotkey v2.0
#SingleInstance Force

; ===== الإعدادات العامة =====
dataPath    := A_ScriptDir "\تسبيح.txt"   ; ملف واحد للعداد والإعدادات
settingsKey := "F1"                        ; مفتاح فتح نافذة الإعدادات

; القيم الافتراضية
incrementKey := "p"
saveExitKey  := "l"
counter      := 0

; ===== قراءة / كتابة ملف واحد =====
LoadData() {
    global dataPath, incrementKey, saveExitKey, counter
    if !FileExist(dataPath)
        return

    content := FileRead(dataPath, "UTF-8")
    for line in StrSplit(content, "`n", "`r") {
        if RegExMatch(line, "^\s*inc\s*=\s*(.+?)\s*$", &m)
            incrementKey := m[1]
        else if RegExMatch(line, "^\s*exit\s*=\s*(.+?)\s*$", &m)
            saveExitKey := m[1]
        else if RegExMatch(line, "^\s*count\s*=\s*(\d+)\s*$", &m)
            counter := Integer(m[1])
    }
}

SaveData() {
    global dataPath, incrementKey, saveExitKey, counter
    if FileExist(dataPath)
        FileDelete(dataPath)

    FileAppend("inc=" incrementKey "`nexit=" saveExitKey "`ncount=" counter "`n", dataPath, "UTF-8")
}

; ===== رسالة سريعة =====
ShowTip(text, ms := 800) {
    ToolTip(text)
    SetTimer(() => ToolTip(), -ms)
}

; ===== تسجيل الحروف =====
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
    global counter
    SaveData()
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

    SaveData()
    RegisterHotkeys()

    ShowTip("تم حفظ الإعدادات", 1500)
    g.Destroy()
}

; ===== التشغيل =====
LoadData()

if !FileExist(dataPath)
    SaveData()

RegisterHotkeys()
Hotkey(settingsKey, ShowSettings)

ShowTip("العدد الحالي: " counter "`n(اضغط " settingsKey " لفتح الإعدادات)", 2500)
