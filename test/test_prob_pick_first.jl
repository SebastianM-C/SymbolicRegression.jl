println("Testing whether tournament_selection_p works.")
using SymbolicRegression
using DynamicExpressions.EquationModule: with_type_parameters
include("test_params.jl")

n = 10

options = Options(;
    default_params...,
    binary_operators=(+, -, *, /),
    unary_operators=(cos, sin),
    tournament_selection_p=0.999,
    tournament_selection_n=n,
)

for reverse in [false, true]
    T = Float32
    NT = with_type_parameters(options.node_type, T)
    members = PopMember{T,T,NT}[]

    # Generate members with scores from 0 to 1:
    for i in 1:n
        tree = Node("x1") * 3.2f0
        score = Float32(i - 1) / (n - 1)
        if reverse
            score = 1 - score
        end
        test_loss = 1.0f0  # (arbitrary for this test)
        push!(members, PopMember(tree, score, test_loss, options))
    end

    pop = Population(members)

    dummy_running_stats = SymbolicRegression.AdaptiveParsimonyModule.RunningSearchStatistics(;
        options=options
    )
    best_pop_member = [
        SymbolicRegression.best_of_sample(pop, dummy_running_stats, options).score for
        j in 1:100
    ]

    mean_value = sum(best_pop_member) / length(best_pop_member)

    # Make sure average score is small
    @test mean_value < 0.1
end

println("Passed.")
