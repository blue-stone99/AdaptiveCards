import AdaptiveCards_bridge
import AppKit

class ActionSetRenderer: NSObject, BaseCardElementRendererProtocol {
    static let shared = ActionSetRenderer()
    
    func render(element: ACSBaseCardElement, with hostConfig: ACSHostConfig, style: ACSContainerStyle, rootView: ACRView, parentView: NSView, inputs: [BaseInputHandler], config: RenderConfig) -> NSView {
        guard let actionSet = element as? ACSActionSet else {
            logError("Element is not of type ACSActionSet")
            return NSView()
        }
        return renderView(actions: actionSet.getActions(), aligned: actionSet.getHorizontalAlignment(), with: hostConfig, style: style, rootView: rootView, parentView: parentView, inputs: inputs, config: config)
    }
    
    func renderActionButtons(actions: [ACSBaseActionElement], with hostConfig: ACSHostConfig, style: ACSContainerStyle, rootView: ACRView, parentView: NSView, inputs: [BaseInputHandler], config: RenderConfig) -> NSView {
        // This renders Action in AdaptiveCards, as it has no
        // horizontal alignment property, hardcode it to .left
        return renderView(actions: actions, aligned: .left, with: hostConfig, style: style, rootView: rootView, parentView: parentView, inputs: inputs, config: config)
    }
    
    private func renderView(actions: [ACSBaseActionElement], aligned alignment: ACSHorizontalAlignment, with hostConfig: ACSHostConfig, style: ACSContainerStyle, rootView: ACRView, parentView: NSView, inputs: [BaseInputHandler], config: RenderConfig) -> NSView {
        let actionsConfig = hostConfig.getActions()
        let actionsOrientation = actionsConfig?.actionsOrientation ?? .vertical
        let actionsButtonSpacing = actionsConfig?.buttonSpacing ?? 8
        let maxAllowedActions = Int(truncating: actionsConfig?.maxActions ?? 10)
        
        if actions.count > maxAllowedActions {
            logError("WARNING: Some actions were not rendered due to exceeding the maximum number \(maxAllowedActions) actions are allowed")
        }
        
        let resolvedCount = min(actions.count, maxAllowedActions)
        let filteredActions = actions[0 ..< resolvedCount]
        let actionViews: [NSView] = filteredActions.map {
            let renderer = RendererManager.shared.actionRenderer(for: $0.getType())
            return renderer.render(action: $0, with: hostConfig, style: style, rootView: rootView, parentView: rootView, inputs: [], config: config)
        }
        
        guard !filteredActions.isEmpty else {
            logError("Actions is empty")
            return NSView()
        }
        
        let orientation: NSUserInterfaceLayoutOrientation
        switch actionsOrientation {
        case .horizontal: orientation = .horizontal
        case .vertical: orientation = .vertical
        @unknown default: orientation = .vertical
        }
        
        let resolvedAlignment: NSLayoutConstraint.Attribute
        switch alignment {
        case .center: resolvedAlignment = orientation == .horizontal ? .centerY : .centerX
        case .left: resolvedAlignment = .leading
        case .right: resolvedAlignment = .trailing
        @unknown default: resolvedAlignment = .leading
        }
        
        return ACRActionSetView(actions: actionViews, orientation: orientation, alignment: resolvedAlignment, spacing: CGFloat(exactly: actionsButtonSpacing) ?? 8)
    }
}
