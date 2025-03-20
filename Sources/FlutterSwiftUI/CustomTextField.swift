import SwiftUI
import Combine

/// A customizable text input component with validation, styling, and controller support
public struct CustomTextField: View {
    // MARK: - Configuration Properties
    
    /// Text editing controller for programmatic control
    @ObservedObject var controller: TextEditingController
    /// Placeholder text
    let placeholder: String
    /// Label text
    let label: String?
    /// Hint text
    let hintText: String?
    /// Input type (text, secure, email, etc.)
    let inputType: InputType
    /// Whether the field is disabled
    let disabled: Bool
    /// Whether the field is read-only
    let readOnly: Bool
    /// Whether the field is required
    let required: Bool
    /// Validation function
    let validator: ((String) -> String?)?
    /// Error message to display
    let error: String?
    /// Full width flag
    let fullWidth: Bool
    /// Maximum character count
    let maxLength: Int?
    /// Text color
    let textColor: Color
    /// Background color
    let backgroundColor: Color
    /// Padding values
    let padding: EdgeInsets
    /// Prefix icon
    let prefixIcon: AnyView?
    /// Suffix icon
    let suffixIcon: AnyView?
    /// Cursor color
    let cursorColor: Color
    /// Whether to obscure text (for passwords)
    let obscureText: Bool
    /// Filled style flag
    let filled: Bool
    /// Outlined style flag
    let outlined: Bool
    /// Underlined style flag
    let underlined: Bool
    /// Keyboard type
    let keyboardType: UIKeyboardType
    
    // MARK: - State Management
    
    @State private var validationError: String?
    @State private var isFocused: Bool = false
    
    // MARK: - Initialization
    
    public init(
        controller: TextEditingController = TextEditingController(),
        placeholder: String = "",
        label: String? = nil,
        hintText: String? = nil,
        inputType: InputType = .text,
        disabled: Bool = false,
        readOnly: Bool = false,
        required: Bool = false,
        validator: ((String) -> String?)? = nil,
        error: String? = nil,
        fullWidth: Bool = true,
        maxLength: Int? = nil,
        textColor: Color = .primary,
        backgroundColor: Color = .clear,
        padding: EdgeInsets = EdgeInsets(top: 10, leading: 12, bottom: 10, trailing: 12),
        prefixIcon: AnyView? = nil,
        suffixIcon: AnyView? = nil,
        cursorColor: Color = .blue,
        obscureText: Bool = false,
        filled: Bool = false,
        outlined: Bool = false,
        underlined: Bool = false,
        keyboardType: UIKeyboardType = .default
    ) {
        self.controller = controller
        self.placeholder = placeholder
        self.label = label
        self.hintText = hintText
        self.inputType = inputType
        self.disabled = disabled
        self.readOnly = readOnly
        self.required = required
        self.validator = validator
        self.error = error
        self.fullWidth = fullWidth
        self.maxLength = maxLength
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.padding = padding
        self.prefixIcon = prefixIcon
        self.suffixIcon = suffixIcon
        self.cursorColor = cursorColor
        self.obscureText = obscureText
        self.filled = filled
        self.outlined = outlined
        self.underlined = underlined
        self.keyboardType = keyboardType
    }
    
    // MARK: - View Body
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            labelView
            inputContainer
            errorView
        }
        .frame(maxWidth: fullWidth ? .infinity : nil)
    }
    
    // MARK: - Subviews
    
    private var labelView: some View {
        Group {
            if let label = label {
                Text(required ? "\(label)*" : label)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var inputContainer: some View {
        HStack(spacing: 0) {
            prefixIcon
            inputField
            suffixIcon
        }
        .padding(padding)
        .background(backgroundView)
        .overlay(borderOverlay)
        .disabled(disabled || readOnly)
    }
    
    private var inputField: some View {
        Group {
            if obscureText {
                SecureField(placeholder, text: $controller.text)
            } else if inputType == .multiline {
                TextEditor(text: $controller.text)
                    .frame(minHeight: 40, idealHeight: 40, maxHeight: .infinity)
            } else {
                TextField(placeholder, text: $controller.text)
                    .keyboardType(keyboardType)
            }
        }
        .foregroundColor(textColor)
        .accentColor(cursorColor)
        .onReceive(controller.$text.debounce(for: 0.3, scheduler: RunLoop.main)) { _ in
            validateInput()
        }
        .onChange(of: controller.text) { newValue in
            if let maxLength = maxLength, newValue.count > maxLength {
                controller.text = String(newValue.prefix(maxLength))
            }
        }
    }
    
    private var backgroundView: some View {
        backgroundColor
            .cornerRadius(4)
            .opacity(filled ? 1 : 0)
    }
    
    private var borderOverlay: some View {
        Group {
            if outlined {
                RoundedRectangle(cornerRadius: 4)
                    .strokeBorder(isFocused ? cursorColor : Color.gray, lineWidth: 2)
            } else if underlined {
                VStack {
                    Spacer()
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(isFocused ? cursorColor : Color.gray)
                }
            }
        }
    }
    
    private var errorView: some View {
        Group {
            if let error = error ?? validationError {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .transition(.opacity)
            }
        }
    }
    
    // MARK: - Validation
    
    private func validateInput() {
        if let validator = validator {
            validationError = validator(controller.text)
        }
    }
}

// MARK: - Supporting Types


/// Input type enumeration
public enum InputType {
    case text
    case secure
    case email
    case number
    case multiline
}

// MARK: - Preview

struct CustomTextField_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            CustomTextField(
                controller: TextEditingController(),
                placeholder: "Enter your email",
                label: "Email",
                inputType: .email,
                required: true,
                validator: { text in
                    text.isEmpty ? "Email is required" : nil
                },
                keyboardType: .emailAddress
            )
            
            CustomTextField(
                placeholder: "Password",
                inputType: .secure,
                backgroundColor: Color(.systemGray6), filled: true
            )
            
            CustomTextField(
                placeholder: "Multiline input",
                inputType: .multiline,
                outlined: true
            )
            .frame(height: 100)
        }
        .padding()
    }
}
