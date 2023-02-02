import 'package:clean_architecture_tdd/app/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NumberTriviaPage extends StatelessWidget {
  const NumberTriviaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final numberTriviaCtrl = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Number Trivia'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BlocBuilder<NumberTriviaBloc, NumberTriviaState>(
            builder: (context, state) {
              if (state is Error) return Text(state.message);

              if (state is Loading) return const CircularProgressIndicator();

              if (state is Loaded) {
                return Padding(
                  padding: const EdgeInsets.all(22.0),
                  child: Column(
                    children: [
                      Text(
                        '${state.trivia.number}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(state.trivia.text)
                    ],
                  ),
                );
              }

              return Container();
            },
          ),
          Padding(
            padding: const EdgeInsets.all(22.0),
            child: TextFormField(
              controller: numberTriviaCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                label: Text('Search Number'),
                isDense: true,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  context.read<NumberTriviaBloc>().add(
                        GetTriviaForConcreteNumber(numberTriviaCtrl.text),
                      );
                },
                child: const Text('Search'),
              ),
              ElevatedButton(
                onPressed: () {
                  context
                      .read<NumberTriviaBloc>()
                      .add(GetTriviaForRandomNumber());
                },
                child: const Text('Random'),
              ),
            ],
          )
        ],
      ),
    );
  }
}
