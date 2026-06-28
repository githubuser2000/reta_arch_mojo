@startuml
skinparam objectAttributeIconSize 0

object topology as "topology:RetaContextTopology"
object schema as "schema:RetaContextSchema"
object context_all as "all:ContextSelection"
object context_html as "html_context:ContextSelection"

topology --> schema
topology --> context_all
context_all --> context_html : refine(output=html)

object presheaves as "presheaves:PresheafBundle"
object csv as "csv:FilesystemPresheaf"
object translations as "translations:FilesystemPresheaf"
object assets as "assets:FilesystemPresheaf"
object prompt_state as "prompt_state:PromptStatePresheaf"
object section_csv as "csv_section:LocalSection"
object section_prompt as "prompt_section:LocalSection"

presheaves --> csv
presheaves --> translations
presheaves --> assets
presheaves --> prompt_state
csv --> section_csv
prompt_state --> section_prompt
section_csv --> context_all
section_prompt --> context_all

object sheaves as "sheaves:SheafBundle"
object parameter_semantics as "parameter_semantics:ParameterSemanticsSheaf"
object generated_columns as "generated_columns:GeneratedColumnsSheaf"
object table_output_sheaf as "table_output:TableOutputSheaf"
object html_refs as "html_refs:HtmlReferenceSheaf"

sheaves --> parameter_semantics
sheaves --> generated_columns
sheaves --> table_output_sheaf
sheaves --> html_refs
parameter_semantics --> topology
parameter_semantics --> presheaves : glue()

object morphisms as "morphisms:MorphismBundle"
object aliases as "aliases:AliasMorphisms"
object ranges as "ranges:RangeMorphisms"
object prompts as "prompts:PromptMorphisms"
object renderers as "renderers:RendererMorphisms"

morphisms --> aliases
morphisms --> ranges
morphisms --> prompts
morphisms --> renderers

object category_bundle as "category_bundle:CategoryTheoryBundle"
object context_category as "OpenRetaContextCategory:CategorySpec"
object sheaf_category as "CanonicalSemanticSheafCategory:CategorySpec"
object table_category as "TableSectionCategory:CategorySpec"
object output_category as "OutputFormatCategory:CategorySpec"
object functor_table as "TableGenerationGluingFunctor:FunctorSpec"
object functor_output as "OutputRenderingFunctorFamily:FunctorSpec"

category_bundle --> context_category
category_bundle --> sheaf_category
category_bundle --> table_category
category_bundle --> output_category
category_bundle --> functor_table
category_bundle --> functor_output

functor_table --> sheaf_category : source
functor_table --> table_category : target
functor_output --> table_category : source
functor_output --> output_category : target

object tables_runtime as "tables_runtime:TableRuntimeBundle"
object tables as "tables:Tables"
object maintable as "maintable:Maintable"
object table_state as "table_state:TableStateBundle"
object table_sections as "table_sections:TableStateSections"
object display_state as "display_state:TableDisplayState"
object generated_section as "generated_section:GeneratedColumnSection"
object table_output as "table_output:TableOutput"

tables_runtime --> tables
tables --> maintable
tables_runtime --> table_state
table_state --> table_sections
table_sections --> display_state
table_sections --> generated_section
table_output_sheaf --> table_output

object execution as "execution:ExecutionNetworkBundle"
object config as "config:ExecutionNetworkConfig"
object fifo as "fifo:FifoTaskQueue"
object lifo as "lifo:LifoTaskStack"
object priority as "priority:PriorityTaskQueue"
object semaphore as "semaphore:ResourceSemaphore"
object half_channel as "half_channel:HalfDuplexChannel"
object full_channel as "full_channel:FullDuplexChannel"
object task1 as "task1:ExecutionTask"
object task2 as "task2:ExecutionTask"
object result1 as "result1:ExecutionResult"

execution --> config
execution --> fifo
execution --> lifo
execution --> priority
execution --> semaphore
execution --> half_channel
execution --> full_channel
fifo --> task1
priority --> task2
result1 --> task1

object persistence as "persistence:PersistenceBundle"
object persistence_config as "persistence_config:PersistenceConfig"

persistence --> persistence_config
persistence --> context_all : save context
persistence --> section_csv : save section
persistence --> sheaves : save snapshot
persistence --> execution : save run/cache/audit

object prompt_runtime as "prompt_runtime:PromptRuntimeBundle"
object prompt_session as "prompt_session:PromptSession"
object prompt_bundle as "prompt_bundle:PromptSessionBundle"
object prompt_text as "prompt_text:PromptTextState"
object word_completer as "word_completer:ArchitectureWordCompleter"
object nested_completer as "nested_completer:ArchitectureNestedCompleter"

prompt_runtime --> prompt_session
prompt_session --> prompt_bundle
prompt_bundle --> prompt_text
prompt_runtime --> word_completer
prompt_runtime --> nested_completer

@enduml
