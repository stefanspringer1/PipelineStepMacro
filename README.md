# PipelineStepMacro

This package implements the macro `@Step` for functions that should act as steps according to the [Pipeline](https://github.com/stefanspringer1/Pipeline) package.

Instead of writing:

```swift
func myGreeting(during execution: Execution) {
    execution.effectuate(checking: StepID(crossModuleFileDesignation: #file, functionSignature: #function)) {
        print("Hello!")
    }
}
```

you just write:

```swift
@Step func myGreeting(during execution: Execution) {
    print("Hello!")
}
```

The function must have the argument with inner-function name `execution` of type `Execution`.

You can also provide a description of the test as argument to `@Step`:

```swift
@Step("printing hello")
func myGreeting(during execution: Execution) {
    print("Hello!")
}
```

See the included test for a complete example.

The package some code from [SwiftLint](https://github.com/realm/SwiftLint) which is public under the [MIT License](https://github.com/realm/SwiftLint/blob/main/LICENSE).
