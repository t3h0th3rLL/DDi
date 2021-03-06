ScriptName zadYokeEffect extends ActiveMagicEffect

; Libraries
zadYokeQuestScript Property ybq Auto
zadLibs Property Libs Auto

; Cache keystroke ID's
Int Property TweenMenuKey Auto
Int Property SprintKey Auto
Int Property JumpKey Auto
Int Property ForwardKey Auto
Int Property BackKey Auto
Int Property StrafeLeftKey Auto
Int Property StrafeRightKey Auto
Int Property SneakKey Auto

; Internal Variables
Keyword Property zad_DeviousDevice Auto
Idle Property CurrentStandIdle Auto
Actor Property target Auto
bool Property Terminate Auto


Function DoReLoad()
	if target && !Terminate
		PlayBoundIdle(CurrentStandIdle)
		DoRegister()
	EndIf
EndFunction

Function DoRegister()
	if !Terminate && target
		RegisterForSingleUpdate(0.75)
	EndIf
EndFunction


Event OnUpdate()
	if target == libs.PlayerRef && ((Game.IsMenuControlsEnabled() && libs.config.HardcoreEffects) || Game.IsFightingControlsEnabled() )
		if !libs.IsAnimating(target)
			libs.UpdateControls()
		EndIf
	EndIf
	; if target.GetAnimationVariableFloat("Speed") == 0 && !target.IsSneaking()
	;  	PlayBoundIdle(CurrentStandIdle)
	; ElseIf target == libs.PlayerRef || target.GetAnimationVariableFloat("Speed") != 0
	; 	PlayBoundIdle(CurrentStandIdle)
	; EndIf
	If (StorageUtil.GetIntValue(Game.GetPlayer(), "_SD_iEnslaved") != 1) ; SD+ compatibility
		PlayBoundIdle(CurrentStandIdle)
	EndIf
	DoRegister()
EndEvent


Event OnEffectStart(Actor akTarget, Actor akCaster)
	target = akTarget
	if target == libs.PlayerRef
		libs.Log("OnEffectStart(): Yoke")
		Terminate = False
		CurrentStandIdle = libs.YokeIdle01
		UnregisterForAllKeys()
		; Register keypresses for more responsive idles
		TweenMenuKey = Input.GetMappedKey("Tween Menu")
		SprintKey = Input.GetMappedKey("Sprint")
		JumpKey = Input.GetMappedKey("Jump")
		ForwardKey = Input.GetMappedKey("Forward")
		BackKey = Input.GetMappedKey("Back")
		StrafeLeftKey = Input.GetMappedKey("Strafe Left")
		StrafeRightKey = Input.GetMappedKey("Strafe Right")
		SneakKey = Input.GetMappedKey("Sneak")
		RegisterForKey(SprintKey)
		RegisterForKey(JumpKey)
		RegisterForKey(TweenMenuKey)
		RegisterForKey(ForwardKey)
		RegisterForKey(BackKey)
		RegisterForKey(StrafeLeftKey)
		RegisterForKey(StrafeRightKey)
		RegisterForKey(SneakKey)
		PlayBoundIdle(CurrentStandIdle)
		DoRegister()
		libs.UpdateControls()
	Endif
EndEvent


Event OnEffectFinish(Actor akTarget, Actor akCaster)
	Terminate = True
	if target == libs.PlayerRef
		libs.Log("OnEffectFinish(): Yoke")
		Debug.SendAnimationEvent(target, "IdleForceDefaultState")
		libs.UpdateControls()
		; UnregisterForAllKeys() ; Not necessary: Automatically unregistered on effect expiration
	EndIf
EndEvent


Event OnKeyDown(Int KeyCode) 
	PlayBoundIdle(CurrentStandIdle); Work around pose issue from skyrim limitations by reapplying on sprint.
	if !Game.IsMenuControlsEnabled() && KeyCode == TweenMenuKey && !UI.IsMenuOpen("Dialogue Menu") && !UI.IsMenuOpen("BarterMenu") && !UI.IsMenuOpen("ContainerMenu") && !UI.IsMenuOpen("Sleep/Wait Menu")
		ybq.ShowDeviceMenu()
	EndIf
EndEvent


Event OnKeyUp(int KeyCode, float HoldTime) ; Reduce time player slides around during transition from other animation's  by quickly beginning offset animation
	if KeyCode == StrafeLeftKey || KeyCode == StrafeRightKey || KeyCode == ForwardKey || KeyCode == BackKey
		if KeyCode == SneakKey || target.IsSneaking()
			PlayBoundIdle(CurrentStandIdle)
		else
			if !(Input.IsKeyPressed(StrafeLeftKey) || Input.IsKeyPressed(StrafeRightKey) || Input.IsKeyPressed(ForwardKey) || Input.IsKeyPressed(BackKey))
				PlayBoundIdle(CurrentStandIdle)
			EndIf
		EndIf
	EndIf
EndEvent

Function PlayBoundIdle(idle theIdle)
	if !Terminate && libs.IsValidActor(target) && !libs.IsAnimating(target) && !target.IsInFaction(libs.SexLabAnimatingFaction) 
		libs.ApplyBoundAnim(target, theIdle)
	EndIf
EndFunction

Event OnCellLoad()
	DoReLoad()
EndEvent

Event OnCellAttach()
	DoReLoad()
EndEvent

Event OnLoad()
	DoReLoad()
EndEvent

