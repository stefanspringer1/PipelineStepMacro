import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import Testing
import Pipeline
import StepMacro

@Suite(.serialized) struct StepMacroTests {
    
    let metadata = MyMetaData(
        applicationName: "myapp",
        processID: "precess123",
        workItemInfo: "item123"
    )
    
    @Test func testExecution() throws {
        
        @Step("doing something in step 1")
        func step1(during execution: Execution, stopStep2a: Bool = false) {
            #expect(execution.level == 1)
            execution.optional(named: "step2", description: "we usually do not step2") {
                #expect(execution.level == 2) // .........................
                step2a(during: execution, stop: stopStep2a)
                execution.doing("calling step2b in step1") {
                    #expect(execution.level == 3)
                    step2b(during: execution)
                }
            }
        }
        
        let secondStepNumber = 2
        
        @Step("doing something in step \(secondStepNumber)")
        func step2a(during execution: Execution, stop: Bool = false) {
            #expect(execution.level == 3)
            execution.dispensable(named: "calling step3a and step3b in step2a", description: "we might want to skip step3a and step3b in step2a") {
                #expect(execution.level == 4)
                step3a(during: execution)
                if stop {
                    execution.stop(reason: "for some reason")
                }
                step3b(during: execution)
            }
        }
        
        @Step
        func step2b(during execution: Execution) {
            execution.dispensable(named: "calling step3a in step2b", description: "we might want to skip step3a in step2b") {
                step3a(during: execution)
                execution.force {
                    step3a(during: execution)
                }
            }
        }
        
        @Step
        func step3a(during execution: Execution) {
            step4(during: execution)
        }
        
        @Step
        func step3b(during execution: Execution) {
            // -
        }
        
        @Step("a step")
        func step4(during execution: Execution) {
            execution.log(.info, "we are in step 4")
        }
        
        do {
            let logger = CollectingLogger()
            let myExecutionEventProcessor = ExecutionEventProcessorForLogger(withMetaDataInfo: metadata.description, logger: logger, excutionInfoFormat: ExecutionInfoFormat(addIndentation: true))
            
            let execution = Execution(executionEventProcessor: myExecutionEventProcessor)
            
            step1(during: execution)
            
            #expect(logger.messages.joined(separator: "\n") == """
                beginning step step1(during:stopStep2a:)@\(#file.firstPathPart) (doing something in step 1)
                    skipping optional part "step2" (we usually do not step2)
                ending step step1(during:stopStep2a:)@\(#file.firstPathPart) (doing something in step 1)
                """)
        }
        
        do {
            let logger = CollectingLogger()
            let myExecutionEventProcessor = ExecutionEventProcessorForLogger(withMetaDataInfo: metadata.description, logger: logger, excutionInfoFormat: ExecutionInfoFormat(addIndentation: true))
            
            let execution = Execution(executionEventProcessor: myExecutionEventProcessor, withOptions: ["step2"])
            
            step1(during: execution)
            
            #expect(logger.messages.joined(separator: "\n") == """
                beginning step step1(during:stopStep2a:)@\(#file.firstPathPart) (doing something in step 1)
                    beginning optional part "step2" (we usually do not step2)
                        beginning step step2a(during:stop:)@\(#file.firstPathPart) (doing something in step 2)
                            beginning dispensible part "calling step3a and step3b in step2a" (we might want to skip step3a and step3b in step2a)
                                beginning step step3a(during:)@\(#file.firstPathPart)
                                    beginning step step4(during:)@\(#file.firstPathPart) (a step)
                                        we are in step 4
                                    ending step step4(during:)@\(#file.firstPathPart) (a step)
                                ending step step3a(during:)@\(#file.firstPathPart)
                                beginning step step3b(during:)@\(#file.firstPathPart)
                                ending step step3b(during:)@\(#file.firstPathPart)
                            ending dispensible part "calling step3a and step3b in step2a" (we might want to skip step3a and step3b in step2a)
                        ending step step2a(during:stop:)@\(#file.firstPathPart) (doing something in step 2)
                        beginning "calling step2b in step1"
                            beginning step step2b(during:)@\(#file.firstPathPart)
                                beginning dispensible part "calling step3a in step2b" (we might want to skip step3a in step2b)
                                    skipping previously executed step step3a(during:)@\(#file.firstPathPart)
                                    beginning forcing steps
                                        beginning forced step step3a(during:)@\(#file.firstPathPart)
                                            skipping previously executed step step4(during:)@\(#file.firstPathPart) (a step)
                                        ending forced step step3a(during:)@\(#file.firstPathPart)
                                    ending forcing steps
                                ending dispensible part "calling step3a in step2b" (we might want to skip step3a in step2b)
                            ending step step2b(during:)@\(#file.firstPathPart)
                        ending "calling step2b in step1"
                    ending optional part "step2" (we usually do not step2)
                ending step step1(during:stopStep2a:)@\(#file.firstPathPart) (doing something in step 1)
                """)
        }
        
        do {
            let logger = CollectingLogger()
            let myExecutionEventProcessor = ExecutionEventProcessorForLogger(withMetaDataInfo: metadata.description, logger: logger, excutionInfoFormat: ExecutionInfoFormat(addIndentation: true))
            
            let execution = Execution(executionEventProcessor: myExecutionEventProcessor, withOptions: ["step2"], dispensingWith: ["calling step3a in step2b"])
            
            step1(during: execution)
            
            #expect(logger.messages.joined(separator: "\n") == """
                beginning step step1(during:stopStep2a:)@\(#file.firstPathPart) (doing something in step 1)
                    beginning optional part "step2" (we usually do not step2)
                        beginning step step2a(during:stop:)@\(#file.firstPathPart) (doing something in step 2)
                            beginning dispensible part "calling step3a and step3b in step2a" (we might want to skip step3a and step3b in step2a)
                                beginning step step3a(during:)@\(#file.firstPathPart)
                                    beginning step step4(during:)@\(#file.firstPathPart) (a step)
                                        we are in step 4
                                    ending step step4(during:)@\(#file.firstPathPart) (a step)
                                ending step step3a(during:)@\(#file.firstPathPart)
                                beginning step step3b(during:)@\(#file.firstPathPart)
                                ending step step3b(during:)@\(#file.firstPathPart)
                            ending dispensible part "calling step3a and step3b in step2a" (we might want to skip step3a and step3b in step2a)
                        ending step step2a(during:stop:)@\(#file.firstPathPart) (doing something in step 2)
                        beginning "calling step2b in step1"
                            beginning step step2b(during:)@\(#file.firstPathPart)
                                skipping dispensible part "calling step3a in step2b" (we might want to skip step3a in step2b)
                            ending step step2b(during:)@\(#file.firstPathPart)
                        ending "calling step2b in step1"
                    ending optional part "step2" (we usually do not step2)
                ending step step1(during:stopStep2a:)@\(#file.firstPathPart) (doing something in step 1)
                """)
        }
        
        do {
            let logger = CollectingLogger()
            let myExecutionEventProcessor = ExecutionEventProcessorForLogger(withMetaDataInfo: metadata.description, logger: logger, excutionInfoFormat: ExecutionInfoFormat(addIndentation: true))
            
            let execution = Execution(executionEventProcessor: myExecutionEventProcessor, withOptions: ["step2"])
            
            step1(during: execution, stopStep2a: true)
            
            #expect(logger.messages.joined(separator: "\n") == """
                beginning step step1(during:stopStep2a:)@\(#file.firstPathPart) (doing something in step 1)
                    beginning optional part "step2" (we usually do not step2)
                        beginning step step2a(during:stop:)@\(#file.firstPathPart) (doing something in step 2)
                            beginning dispensible part "calling step3a and step3b in step2a" (we might want to skip step3a and step3b in step2a)
                                beginning step step3a(during:)@\(#file.firstPathPart)
                                    beginning step step4(during:)@\(#file.firstPathPart) (a step)
                                        we are in step 4
                                    ending step step4(during:)@\(#file.firstPathPart) (a step)
                                ending step step3a(during:)@\(#file.firstPathPart)
                                stopping execution: for some reason
                                skipping in an stopped environment step step3b(during:)@\(#file.firstPathPart)
                            ending dispensible part "calling step3a and step3b in step2a" (we might want to skip step3a and step3b in step2a)
                        stopped step step2a(during:stop:)@\(#file.firstPathPart) (doing something in step 2)
                        beginning "calling step2b in step1"
                            skipping in an stopped environment step step2b(during:)@\(#file.firstPathPart)
                        ending "calling step2b in step1"
                    ending optional part "step2" (we usually do not step2)
                stopped step step1(during:stopStep2a:)@\(#file.firstPathPart) (doing something in step 1)
                """)
        }
        
    }
    
}
