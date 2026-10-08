import 'package:flutter/material.dart';
import 'package:smart_layout/smart_layout.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Layout Test',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        useMaterial3: true,
      ),
      home: const LandingPage(),
    );
  }
}

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AutoElement(
          referenceWidth: 1200, // Toda a tela vai usar 1200 como padrao de tamanho 1.0!
          child: ResponsiveBox(
          layoutMode: ResponsiveLayoutMode.column,
          scrollable: true,
          fullWidth: true,
          fullHeight: true,
          children: [
            // ==========================================
            // 1. HEADER (Testando o Responsive Collapse)
            // ==========================================
            ResponsiveBox(
              fullWidth: true, // Garante que tome 100% da tela
              layoutMode: ResponsiveLayoutMode.row,
              align: 'between, center',
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              backgroundColor: Colors.white,
              collapseBreakpoint: 800, // No tablet/mobile, ele colapsa
              collapseIconPosition: ResponsiveCollapsePosition.center, // Coloca o icone entre o Logo e o Botão!
              children: [
                // Logo
                const Text(
                  'SMART.', 
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -1)
                ),
                
                // Itens Colapsaveis
                ResponsiveCollapse(
                  collapsedChild: const ListTile(leading: Icon(Icons.home), title: Text('Home')),
                  child: TextButton(onPressed: (){}, child: const Text('Home')),
                ),
                ResponsiveCollapse(
                  collapsedChild: const ListTile(leading: Icon(Icons.bolt), title: Text('Funcionalidades')),
                  child: TextButton(onPressed: (){}, child: const Text('Funcionalidades')),
                ),
                ResponsiveCollapse(
                  collapsedChild: const ListTile(leading: Icon(Icons.auto_awesome), title: Text('AutoElement')),
                  child: TextButton(onPressed: (){}, child: const Text('AutoElement')),
                ),
                ResponsiveCollapse(
                  collapsedChild: const ListTile(leading: Icon(Icons.email), title: Text('Contato')),
                  child: TextButton(onPressed: (){}, child: const Text('Contato')),
                ),

                // Botão de ação (Não colapsa!)
                ElevatedButton(
                  onPressed: (){},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)
                  ),
                  child: const Text('Começar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),

            // ==========================================
            // 2. HERO SECTION (Testando o AutoElement)
            // ==========================================
            ResponsiveBox(
              fullWidth: true,
              layoutMode: ResponsiveLayoutMode.row,
              align: 'center', // Centraliza o conteudo na tela toda
              wrap: true, 
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
              children: [
                ResponsiveBox(
                  widthPercent: 0.9,
                  maxWidth: 800,
                  align: 'center', // Centraliza o texto dentro da propria caixa
                  children: [
                    ResponsiveBox(
                      gap: 24, // Usa a nova feature de Gap Automatico!!
                      align: 'center', 
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1), 
                            borderRadius: BorderRadius.circular(24)
                          ),
                          child: const Text('NOVA BIBLIOTECA V1.0', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                        ),
                        const Text(
                          'Construa layouts impecáveis,\nmuito mais rápido.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 48, height: 1.1, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
                        ),
                        const Text(
                          'Com o Smart Layout, seus apps se adaptam a qualquer tela sem dores de cabeça. Abandone o MediaQuery e foque no que realmente importa.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, color: Colors.grey, height: 1.5),
                        ),
                        ResponsiveHide(
                          mobile: true, // Some com essa decoração no mobile para ganhar espaço!
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Icon(Icons.star, color: Colors.amber, size: 32),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: (){},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                          ),
                          child: const Text('Instalar agora', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),

            // ==========================================
            // 3. CARDS (Testando ResponsiveBox com Wrap)
            // ==========================================
            ResponsiveBox(
              animated: true, // As quebras de linha agora são suaves!
              fullWidth: true,
              layoutMode: ResponsiveLayoutMode.row,
              align: 'center',
              wrap: true, 
              gap: 32,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              children: [
                _buildFeatureCard(Icons.transform, 'AutoElement', 'Os componentes escalam o próprio conteúdo de forma orgânica, sem zoom bruto.'),
                _buildFeatureCard(Icons.layers_outlined, 'ResponsiveBox', 'Controle absoluto com flexbox integrado e sintaxe estilo CSS para alinhamentos.'),
                _buildFeatureCard(Icons.menu_open, 'ResponsiveCollapse', 'Envolva os itens e ganhe uma gaveta mobile automática. Esqueça ifs no layout!'),
              ],
            ),
          ]
        ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String desc) {
    return ResponsiveBox(
      width: 320,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05), 
            blurRadius: 20, 
            offset: const Offset(0, 10)
          )
        ]
      ),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.indigo.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16)
          ),
          child: Icon(icon, size: 32, color: Colors.indigo),
        ),
        const SizedBox(height: 24),
        Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        const SizedBox(height: 12),
        Text(desc, style: const TextStyle(fontSize: 16, color: Colors.grey, height: 1.5)),
      ]
    );
  }
}
