class_name EnemyState
extends State
## Estado de um inimigo: um `State` com acesso ao contexto compartilhado (corpo, movimento, alvo).

var context: AgentContext


## Recebe o contexto do cérebro; chamado uma vez, antes da primeira transição.
func setup(agent_context: AgentContext) -> void:
	context = agent_context
