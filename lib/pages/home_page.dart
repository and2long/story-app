import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ytnavigator/flutter_ytnavigator.dart';
import 'package:story/components/global_overlay.dart';
import 'package:story/components/player_bottom_bar.dart';
import 'package:story/components/yt_network_image.dart';
import 'package:story/core/blocs/category/category_cubit.dart';
import 'package:story/core/blocs/category/category_state.dart';
import 'package:story/models/story_category.dart';
import 'package:story/pages/settings_page.dart';
import 'package:story/pages/story_list_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, List<StoryCategory>> _groupedItems = {};

  @override
  void initState() {
    super.initState();
    _fetchData();
    Future.delayed(Duration.zero, () {
      // ignore: use_build_context_synchronously
      GlobalOverlay.show(context: context, view: const PlayerBottomBar());
    });
  }

  _fetchData() {
    context.read<CategoryCubit>().getCategoryList();
  }

  void _groupCategoriesByTheme(List<StoryCategory> items) {
    final Map<String, List<StoryCategory>> groupedItems = {};
    for (var item in items) {
      if (!groupedItems.containsKey(item.theme)) {
        groupedItems[item.theme] = [];
      }
      groupedItems[item.theme]!.add(item);
    }
    setState(() {
      _groupedItems = groupedItems;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CategoryCubit, CategoryState>(
      listener: (BuildContext context, CategoryState state) {
        if (state is CategoryListSuccessState) {
          _groupCategoriesByTheme(state.items);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Icon(
                Icons.auto_stories_rounded,
                color: Theme.of(context).primaryColor,
                size: 32,
              ),
              const SizedBox(width: 12),
              const Text(
                '儿童故事天地',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.settings, color: Theme.of(context).primaryColor),
              onPressed: () {
                NavigatorUtil.push(context, SettingsPage());
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            _fetchData();
          },
          child: CustomScrollView(
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final theme = _groupedItems.keys.elementAt(index);
                  final categories = _groupedItems[theme]!;
                  return _buildThemeSection(theme, categories);
                }, childCount: _groupedItems.keys.length),
              ),
              SliverPadding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom + 100,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeSection(String theme, List<StoryCategory> categories) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              theme,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 240,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return Container(
                  margin: EdgeInsets.only(left: 10),
                  child: HomeCategoryCard(category: category),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class HomeCategoryCard extends StatelessWidget {
  final StoryCategory category;

  const HomeCategoryCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 160,
        child: InkWell(
          onTap: () {
            NavigatorUtil.push(context, StoryListPage(category: category));
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: 'category_${category.name}',
                      child: YTNetworkImage(
                        imageUrl: category.cover,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.3),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '${category.count} 个故事',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6),
                      Text(
                        category.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
