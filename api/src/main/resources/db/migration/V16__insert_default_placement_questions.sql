INSERT INTO placement_questions (language_id, level, question, correct_answer, options, created_at) VALUES

(1, 'N1', 'Ele ___ muito cedo para trabalhar.', 'acorda', '["acorda", "acordam", "acorde", "acordar"]'::jsonb, NOW()),
(1, 'N1', 'Qual é o plural da palavra "jardim"?', 'jardins', '["jardims", "jardins", "jardines", "jardises"]'::jsonb, NOW()),
(1, 'N1', '___ água está muito gelada.', 'A', '["O", "A", "Um", "Os"]'::jsonb, NOW()),
(1, 'N1', 'Qual o oposto da palavra "rápido"?', 'lento', '["devagar", "lento", "baixo", "curto"]'::jsonb, NOW()),
(1, 'N1', 'Nós ___ ao cinema ontem à noite.', 'fomos', '["fomos", "vai", "fui", "irão"]'::jsonb, NOW()),

(1, 'N2', 'Fiquei surpreso ___ sua atitude.', 'com', '["de", "com", "em", "por"]'::jsonb, NOW()),
(1, 'N2', 'Qual das frases apresenta o uso correto de "por que"?', 'Por que você não foi à reunião?', '["Por que você não foi à reunião?", "Não fui porque estava chovendo por que?", "Ele não veio porquê estava doente.", "Ainda não entendi o por que de tudo isso."]'::jsonb, NOW()),
(1, 'N2', 'Assinale a opção com a concordância correta:', 'Fazem três anos que não o vejo.', '["Haviam muitas pessoas na festa.", "Fazem três anos que não o vejo.", "Houve muitos problemas no projeto.", "Existe muitas dúvidas sobre o tema."]'::jsonb, NOW()),
(1, 'N2', 'Indique o sinônimo adequado da palavra "imprescindível":', 'indispensável', '["desnecessário", "secundário", "indispensável", "irrelevante"]'::jsonb, NOW()),
(1, 'N2', 'Se você ___ com calma, resolveria o problema.', 'falasse', '["falar", "falasse", "falaria", "fale"]'::jsonb, NOW()),

(1, 'N3', 'Assinale a alternativa em que a crase foi empregada CORRETAMENTE:', 'Agradeço àqueles que me apoiaram.', '["Entreguei o relatório à ele.", "Ele foi à pé para casa.", "Agradeço àqueles que me apoiaram.", "Chegamos à uma conclusão importante."]'::jsonb, NOW()),
(1, 'N3', 'Qual frase apresenta erro de regência verbal?', 'Assistimos o filme inteiro no domingo.', '["Esqueci o nome daquele autor.", "Assistimos o filme inteiro no domingo.", "Aspirava a um cargo de chefia.", "Preferia sair a ficar em casa."]'::jsonb, NOW()),
(1, 'N3', 'Assinale a figura de linguagem presente em: "O jardim olhava as crianças com carinho."', 'Personificação', '["Metáfora", "Metonímia", "Personificação", "Hipérbole"]'::jsonb, NOW()),
(1, 'N3', 'Em relação à colocação pronominal, assinale a opção correta conforme a norma-padrão:', 'Não me fale sobre este assunto.', '["Me empreste o caneta, por favor.", "Não me fale sobre este assunto.", "Trata-se de uma questão simples, disse-me ele.", "Já disseram-me a verdade ontem."]'::jsonb, NOW()),
(1, 'N3', 'Marque a opção onde o termo destacado é um complemento nominal:', 'A leitura do livro foi enriquecedora.', '["O aluno respondeu ao professor.", "A leitura do livro foi enriquecedora.", "A garota gosta de música clássica.", "O vento soprava com força."]'::jsonb, NOW());

INSERT INTO placement_questions (language_id, level, question, correct_answer, options, created_at) VALUES
(2, 'N1', 'Complete: She ___ a teacher at the local school.', 'is', '["am", "is", "are", "be"]'::jsonb, NOW()),
(2, 'N1', 'What is the plural of "child"?', 'children', '["childs", "children", "childes", "childrens"]'::jsonb, NOW()),
(2, 'N1', 'Fill in the blank: Where ___ you live?', 'do', '["does", "do", "is", "are"]'::jsonb, NOW()),
(2, 'N1', 'Select the correct opposite of "expensive":', 'cheap', '["cheap", "high", "costly", "small"]'::jsonb, NOW()),
(2, 'N1', 'Complete: They ___ to music right now.', 'are listening', '["listened", "are listening", "listens", "were listen"]'::jsonb, NOW()),

(2, 'N2', 'Choose the correct tense: I ___ in London since 2018.', 'have lived', '["lived", "have lived", "am living", "had live"]'::jsonb, NOW()),
(2, 'N2', 'Complete: If it rains tomorrow, we ___ the picnic.', 'will cancel', '["would cancel", "cancelled", "will cancel", "canceling"]'::jsonb, NOW()),
(2, 'N2', 'Select the correct passive form: "They built this house in 1990."', 'This house was built in 1990.', '["This house is built in 1990.", "This house was built in 1990.", "This house has been built in 1990.", "This house were built in 1990."]'::jsonb, NOW()),
(2, 'N2', 'Which phrasal verb means "to give up or stop doing something"?', 'quit', '["look after", "turn down", "quit", "take off"]'::jsonb, NOW()),
(2, 'N2', 'Complete: She is much better ___ playing tennis than her brother.', 'at', '["in", "at", "on", "for"]'::jsonb, NOW()),

(2, 'N3', 'Complete: Had I known about the meeting, I ___ attended.', 'would have', '["will have", "would have", "had", "would"]'::jsonb, NOW()),
(2, 'N3', 'Identify the correct use of a modal verb for deduction about the past: "He wasn''t at work, so he ___ been sick."', 'must have', '["must have", "should have", "can have", "might be"]'::jsonb, NOW()),
(2, 'N3', 'Which word best completes the sentence: The proposal was rejected due to its ___ costs.', 'exorbitant', '["exorbitant", "extravagant", "excessive", "superfluous"]'::jsonb, NOW()),
(2, 'N3', 'Choose the correct inverted structure: Scarcely ___ when the power went out.', 'had he arrived', '["he arrived", "did he arrive", "had he arrived", "he had arrived"]'::jsonb, NOW()),
(2, 'N3', 'What does the idiom "to play devil''s advocate" mean?', 'To argue against an idea for the sake of debate.', '["To support an evil cause.", "To argue against an idea for the sake of debate.", "To make a situation worse.", "To pretend to agree with someone."]'::jsonb, NOW());