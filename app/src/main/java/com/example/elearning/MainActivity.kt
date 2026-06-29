package com.example.elearning

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.animation.*
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.TextFieldValue
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.material3.Surface
import coil.compose.AsyncImage

// ==================== Data Classes ====================

/**
 * Data class representing a Course
 */
data class Course(
    val id: Int,
    val title: String,
    val instructor: String,
    val category: String,
    val rating: Float,
    val students: Int,
    val duration: String,
    val imageUrl: String,
    val description: String,
    val lessons: Int,
    val difficulty: String,
    val progress: Int = 0,
    val isFavorite: Boolean = false,
    val lessons_list: List<Lesson> = emptyList()
)

/**
 * Data class representing a Lesson
 */
data class Lesson(
    val id: Int,
    val title: String,
    val duration: String,
    val isCompleted: Boolean = false
)

/**
 * Data class representing User Profile
 */
data class UserProfile(
    val name: String = "John Doe",
    val email: String = "john.doe@example.com",
    val profileImage: String = "https://via.placeholder.com/150",
    val completedCourses: Int = 12,
    val certificatesEarned: Int = 8,
    val studyHours: Int = 145,
    val learningStreak: Int = 15
)

// ==================== Sample Data ====================

/**
 * Sample courses data - Replace with API calls later
 */
fun getSampleCourses(): List<Course> = listOf(
    Course(
        id = 1,
        title = "Python for Beginners",
        instructor = "Dr. Sarah Johnson",
        category = "Programming",
        rating = 4.8f,
        students = 15234,
        duration = "8 weeks",
        imageUrl = "https://via.placeholder.com/300x150?text=Python",
        description = "Learn Python programming from scratch. Perfect for beginners!",
        lessons = 32,
        difficulty = "Beginner",
        progress = 65,
        isFavorite = true,
        lessons_list = listOf(
            Lesson(1, "Introduction to Python", "45 min", true),
            Lesson(2, "Variables and Data Types", "50 min", true),
            Lesson(3, "Control Structures", "60 min", false)
        )
    ),
    Course(
        id = 2,
        title = "Advanced Mathematics",
        instructor = "Prof. Michael Chen",
        category = "Mathematics",
        rating = 4.9f,
        students = 8976,
        duration = "10 weeks",
        imageUrl = "https://via.placeholder.com/300x150?text=Mathematics",
        description = "Master advanced mathematical concepts including calculus and linear algebra.",
        lessons = 45,
        difficulty = "Advanced",
        progress = 30,
        lessons_list = listOf(
            Lesson(1, "Limits and Continuity", "75 min", true),
            Lesson(2, "Derivatives", "80 min", false),
            Lesson(3, "Integration", "85 min", false)
        )
    ),
    Course(
        id = 3,
        title = "Web Development with React",
        instructor = "Emily Rodriguez",
        category = "Programming",
        rating = 4.7f,
        students = 22100,
        duration = "12 weeks",
        imageUrl = "https://via.placeholder.com/300x150?text=React",
        description = "Build modern web applications with React and JavaScript.",
        lessons = 56,
        difficulty = "Intermediate",
        progress = 45,
        lessons_list = listOf(
            Lesson(1, "React Basics", "60 min", true),
            Lesson(2, "Components and Props", "65 min", true),
            Lesson(3, "State Management", "70 min", false)
        )
    ),
    Course(
        id = 4,
        title = "Artificial Intelligence Fundamentals",
        instructor = "Dr. Alex Kumar",
        category = "Artificial Intelligence",
        rating = 4.6f,
        students = 11234,
        duration = "14 weeks",
        imageUrl = "https://via.placeholder.com/300x150?text=AI",
        description = "Explore the fundamentals of AI, machine learning, and neural networks.",
        lessons = 48,
        difficulty = "Advanced",
        progress = 20,
        lessons_list = listOf(
            Lesson(1, "AI Fundamentals", "90 min", true),
            Lesson(2, "Machine Learning Basics", "95 min", false),
            Lesson(3, "Neural Networks", "100 min", false)
        )
    ),
    Course(
        id = 5,
        title = "Data Science with Python",
        instructor = "Dr. Lisa Wong",
        category = "Data Science",
        rating = 4.8f,
        students = 19856,
        duration = "11 weeks",
        imageUrl = "https://via.placeholder.com/300x150?text=DataScience",
        description = "Learn data analysis, visualization, and machine learning with Python.",
        lessons = 42,
        difficulty = "Intermediate",
        progress = 55,
        isFavorite = true,
        lessons_list = listOf(
            Lesson(1, "Data Fundamentals", "55 min", true),
            Lesson(2, "Pandas and NumPy", "65 min", true),
            Lesson(3, "Data Visualization", "60 min", false)
        )
    ),
    Course(
        id = 6,
        title = "Physics: Mechanics",
        instructor = "Prof. James Newton",
        category = "Physics",
        rating = 4.5f,
        students = 6234,
        duration = "9 weeks",
        imageUrl = "https://via.placeholder.com/300x150?text=Physics",
        description = "Understanding the fundamentals of classical mechanics and motion.",
        lessons = 38,
        difficulty = "Intermediate",
        progress = 0,
        lessons_list = listOf(
            Lesson(1, "Motion and Forces", "70 min", false),
            Lesson(2, "Energy and Work", "75 min", false),
            Lesson(3, "Momentum and Collisions", "70 min", false)
        )
    ),
    Course(
        id = 7,
        title = "Chemistry Essentials",
        instructor = "Dr. Patricia Hall",
        category = "Chemistry",
        rating = 4.4f,
        students = 7890,
        duration = "8 weeks",
        imageUrl = "https://via.placeholder.com/300x150?text=Chemistry",
        description = "Learn the basics of chemistry including atoms, molecules, and reactions.",
        lessons = 35,
        difficulty = "Beginner",
        progress = 80,
        lessons_list = listOf(
            Lesson(1, "Atomic Structure", "50 min", true),
            Lesson(2, "Chemical Bonding", "55 min", true),
            Lesson(3, "Reactions and Equations", "60 min", true)
        )
    ),
    Course(
        id = 8,
        title = "Business Management",
        instructor = "Ms. Victoria Greene",
        category = "Business",
        rating = 4.6f,
        students = 9234,
        duration = "10 weeks",
        imageUrl = "https://via.placeholder.com/300x150?text=Business",
        description = "Master key business management principles and leadership skills.",
        lessons = 40,
        difficulty = "Intermediate",
        progress = 35,
        lessons_list = listOf(
            Lesson(1, "Business Fundamentals", "50 min", true),
            Lesson(2, "Management Strategies", "60 min", true),
            Lesson(3, "Leadership Skills", "65 min", false)
        )
    )
)

/**
 * Get categories
 */
fun getCategories(): List<String> = listOf(
    "All",
    "Mathematics",
    "Physics",
    "Chemistry",
    "Biology",
    "Computer Science",
    "Programming",
    "AI",
    "Data Science",
    "Engineering",
    "Business"
)

// ==================== Main Activity ====================

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            ELearningApp()
        }
    }
}

// ==================== Main App Composable ====================

@Composable
fun ELearningApp() {
    var currentScreen by remember { mutableStateOf<Screen>(Screen.Home) }
    var selectedCourse by remember { mutableStateOf<Course?>(null) }
    var favorites by remember { mutableStateOf(setOf(1, 5)) }
    var userProfile by remember { mutableStateOf(UserProfile()) }

    val isDarkMode = isSystemInDarkTheme()
    val colorScheme = if (isDarkMode) darkColorScheme() else lightColorScheme()

    MaterialTheme(colorScheme = colorScheme) {
        Surface(
            modifier = Modifier.fillMaxSize(),
            color = MaterialTheme.colorScheme.background
        ) {
            when (currentScreen) {
                is Screen.Home -> HomeScreen(
                    onCourseClick = { course ->
                        selectedCourse = course
                        currentScreen = Screen.CourseDetail
                    },
                    onFavoritesClick = { currentScreen = Screen.Favorites },
                    onProfileClick = { currentScreen = Screen.Profile },
                    favorites = favorites,
                    onToggleFavorite = { courseId ->
                        favorites = if (courseId in favorites) {
                            favorites - courseId
                        } else {
                            favorites + courseId
                        }
                    }
                )
                is Screen.CourseDetail -> CourseDetailScreen(
                    course = selectedCourse ?: getSampleCourses()[0],
                    onBack = { currentScreen = Screen.Home },
                    onEnroll = { currentScreen = Screen.Home }
                )
                is Screen.Favorites -> FavoritesScreen(
                    favorites = favorites,
                    onCourseClick = { course ->
                        selectedCourse = course
                        currentScreen = Screen.CourseDetail
                    },
                    onBack = { currentScreen = Screen.Home }
                )
                is Screen.Profile -> ProfileScreen(
                    userProfile = userProfile,
                    onBack = { currentScreen = Screen.Home }
                )
            }
        }
    }
}

// ==================== Screen Enum ====================

sealed class Screen {
    object Home : Screen()
    object CourseDetail : Screen()
    object Favorites : Screen()
    object Profile : Screen()
}

// ==================== Home Screen ====================

@Composable
fun HomeScreen(
    onCourseClick: (Course) -> Unit,
    onFavoritesClick: () -> Unit,
    onProfileClick: () -> Unit,
    favorites: Set<Int>,
    onToggleFavorite: (Int) -> Unit
) {
    var searchText by remember { mutableStateOf(TextFieldValue("")) }
    var selectedCategory by remember { mutableStateOf("All") }
    val allCourses = getSampleCourses()
    val categories = getCategories()

    // Filter courses based on search and category
    val filteredCourses = allCourses.filter { course ->
        (selectedCategory == "All" || course.category == selectedCategory) &&
                (searchText.text.isEmpty() ||
                        course.title.contains(searchText.text, ignoreCase = true) ||
                        course.instructor.contains(searchText.text, ignoreCase = true))
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
    ) {
        // Top App Bar with Profile and Favorites
        TopAppBarSection(
            onProfileClick = onProfileClick,
            onFavoritesClick = onFavoritesClick,
            favoriteCount = favorites.size
        )

        Spacer(modifier = Modifier.height(16.dp))

        // Search Bar
        SearchBar(
            searchText = searchText,
            onSearchTextChange = { searchText = it }
        )

        Spacer(modifier = Modifier.height(16.dp))

        // Categories
        CategoriesSection(
            categories = categories,
            selectedCategory = selectedCategory,
            onCategorySelect = { selectedCategory = it }
        )

        Spacer(modifier = Modifier.height(16.dp))

        // Featured Courses Section
        if (filteredCourses.isNotEmpty()) {
            SectionHeader(title = "Featured Courses")
            FeaturedCoursesCarousel(
                courses = filteredCourses.take(3),
                onCourseClick = onCourseClick,
                favorites = favorites,
                onToggleFavorite = onToggleFavorite
            )
        }

        Spacer(modifier = Modifier.height(16.dp))

        // Continue Learning Section
        val continueLearning = filteredCourses.filter { it.progress > 0 }
        if (continueLearning.isNotEmpty()) {
            SectionHeader(title = "Continue Learning")
            ContinueLearningSection(
                courses = continueLearning,
                onCourseClick = onCourseClick,
                favorites = favorites,
                onToggleFavorite = onToggleFavorite
            )
            Spacer(modifier = Modifier.height(16.dp))
        }

        // Popular Courses Section
        SectionHeader(title = "Popular Courses")
        PopularCoursesSection(
            courses = filteredCourses.sortedByDescending { it.students }.take(5),
            onCourseClick = onCourseClick,
            favorites = favorites,
            onToggleFavorite = onToggleFavorite
        )

        Spacer(modifier = Modifier.height(20.dp))
    }
}

// ==================== UI Components ====================

/**
 * Top App Bar with Profile and Favorites buttons
 */
@Composable
fun TopAppBarSection(
    onProfileClick: () -> Unit,
    onFavoritesClick: () -> Unit,
    favoriteCount: Int
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 12.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Column {
            Text(
                text = "EduLearn",
                fontSize = 28.sp,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colorScheme.primary
            )
            Text(
                text = "Learn Anywhere, Anytime",
                fontSize = 12.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }

        Row(
            horizontalArrangement = Arrangement.spacedBy(8.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Favorites Button
            BadgedBox(
                badge = {
                    if (favoriteCount > 0) {
                        Badge(
                            containerColor = MaterialTheme.colorScheme.error,
                            contentColor = Color.White
                        ) {
                            Text(favoriteCount.toString(), fontSize = 10.sp)
                        }
                    }
                }
            ) {
                IconButton(onClick = onFavoritesClick) {
                    Icon(
                        imageVector = Icons.Filled.Favorite,
                        contentDescription = "Favorites",
                        tint = MaterialTheme.colorScheme.primary
                    )
                }
            }

            // Profile Button
            IconButton(onClick = onProfileClick) {
                Icon(
                    imageVector = Icons.Filled.AccountCircle,
                    contentDescription = "Profile",
                    tint = MaterialTheme.colorScheme.primary,
                    modifier = Modifier.size(32.dp)
                )
            }
        }
    }
}

/**
 * Search Bar Component
 */
@Composable
fun SearchBar(
    searchText: TextFieldValue,
    onSearchTextChange: (TextFieldValue) -> Unit
) {
    OutlinedTextField(
        value = searchText,
        onValueChange = onSearchTextChange,
        placeholder = { Text("Search courses, instructors...") },
        leadingIcon = {
            Icon(
                imageVector = Icons.Default.Search,
                contentDescription = "Search"
            )
        },
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp)
            .clip(RoundedCornerShape(12.dp)),
        singleLine = true,
        shape = RoundedCornerShape(12.dp)
    )
}

/**
 * Categories Section
 */
@Composable
fun CategoriesSection(
    categories: List<String>,
    selectedCategory: String,
    onCategorySelect: (String) -> Unit
) {
    Column(modifier = Modifier.padding(horizontal = 16.dp)) {
        Text(
            text = "Categories",
            fontSize = 16.sp,
            fontWeight = FontWeight.Bold,
            modifier = Modifier.padding(bottom = 12.dp)
        )

        LazyRow(
            horizontalArrangement = Arrangement.spacedBy(8.dp),
            modifier = Modifier.fillMaxWidth()
        ) {
            items(categories) { category ->
                CategoryChip(
                    text = category,
                    isSelected = category == selectedCategory,
                    onClick = { onCategorySelect(category) }
                )
            }
        }
    }
}

/**
 * Category Chip Component
 */
@Composable
fun CategoryChip(
    text: String,
    isSelected: Boolean,
    onClick: () -> Unit
) {
    Button(
        onClick = onClick,
        modifier = Modifier
            .clip(RoundedCornerShape(20.dp))
            .height(36.dp),
        colors = ButtonDefaults.buttonColors(
            containerColor = if (isSelected) MaterialTheme.colorScheme.primary
            else MaterialTheme.colorScheme.surfaceVariant,
            contentColor = if (isSelected) Color.White else MaterialTheme.colorScheme.onSurface
        )
    ) {
        Text(text = text, fontSize = 12.sp)
    }
}

/**
 * Section Header
 */
@Composable
fun SectionHeader(title: String) {
    Text(
        text = title,
        fontSize = 18.sp,
        fontWeight = FontWeight.Bold,
        modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp)
    )
}

/**
 * Featured Courses Carousel
 */
@Composable
fun FeaturedCoursesCarousel(
    courses: List<Course>,
    onCourseClick: (Course) -> Unit,
    favorites: Set<Int>,
    onToggleFavorite: (Int) -> Unit
) {
    LazyRow(
        horizontalArrangement = Arrangement.spacedBy(12.dp),
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp)
    ) {
        items(courses) { course ->
            FeaturedCourseCard(
                course = course,
                onCourseClick = { onCourseClick(course) },
                isFavorite = course.id in favorites,
                onToggleFavorite = { onToggleFavorite(course.id) }
            )
        }
    }
}

/**
 * Featured Course Card
 */
@Composable
fun FeaturedCourseCard(
    course: Course,
    onCourseClick: () -> Unit,
    isFavorite: Boolean,
    onToggleFavorite: () -> Unit
) {
    Card(
        modifier = Modifier
            .width(280.dp)
            .clip(RoundedCornerShape(16.dp))
            .clickable { onCourseClick() },
        elevation = CardDefaults.cardElevation(defaultElevation = 4.dp)
    ) {
        Column {
            // Course Image
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(160.dp)
                    .background(MaterialTheme.colorScheme.surfaceVariant)
            ) {
                AsyncImage(
                    model = course.imageUrl,
                    contentDescription = course.title,
                    modifier = Modifier.fillMaxSize(),
                    contentScale = ContentScale.Crop
                )

                // Favorite Button
                IconButton(
                    onClick = onToggleFavorite,
                    modifier = Modifier
                        .align(Alignment.TopEnd)
                        .padding(8.dp)
                        .background(
                            color = Color.White.copy(alpha = 0.9f),
                            shape = RoundedCornerShape(50)
                        )
                ) {
                    Icon(
                        imageVector = if (isFavorite) Icons.Filled.Favorite
                        else Icons.Outlined.FavoriteBorder,
                        contentDescription = "Favorite",
                        tint = if (isFavorite) Color.Red else Color.Gray,
                        modifier = Modifier.size(20.dp)
                    )
                }
            }

            Column(modifier = Modifier.padding(12.dp)) {
                Text(
                    text = course.title,
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Bold,
                    maxLines = 2
                )

                Text(
                    text = course.instructor,
                    fontSize = 11.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    maxLines = 1
                )

                Spacer(modifier = Modifier.height(8.dp))

                // Rating and Students
                Row(
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(
                            imageVector = Icons.Filled.Star,
                            contentDescription = "Rating",
                            tint = Color.Yellow,
                            modifier = Modifier.size(14.dp)
                        )
                        Text(
                            text = course.rating.toString(),
                            fontSize = 10.sp,
                            fontWeight = FontWeight.Bold
                        )
                    }

                    Text(
                        text = "(${course.students / 1000}k students)",
                        fontSize = 10.sp,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }

                Spacer(modifier = Modifier.height(8.dp))

                // Progress Bar
                if (course.progress > 0) {
                    LinearProgressIndicator(
                        progress = { course.progress / 100f },
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(4.dp)
                            .clip(RoundedCornerShape(2.dp)),
                        color = MaterialTheme.colorScheme.primary,
                        trackColor = MaterialTheme.colorScheme.surfaceVariant
                    )
                    Text(
                        text = "${course.progress}% Complete",
                        fontSize = 9.sp,
                        color = MaterialTheme.colorScheme.primary,
                        fontWeight = FontWeight.Bold
                    )
                }

                Spacer(modifier = Modifier.height(8.dp))

                Button(
                    onClick = onCourseClick,
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(8.dp)
                ) {
                    Text("Start Learning", fontSize = 11.sp)
                }
            }
        }
    }
}

/**
 * Continue Learning Section
 */
@Composable
fun ContinueLearningSection(
    courses: List<Course>,
    onCourseClick: (Course) -> Unit,
    favorites: Set<Int>,
    onToggleFavorite: (Int) -> Unit
) {
    Column(modifier = Modifier.padding(horizontal = 16.dp)) {
        courses.forEach { course ->
            ContinueLearningCard(
                course = course,
                onCourseClick = { onCourseClick(course) },
                isFavorite = course.id in favorites,
                onToggleFavorite = { onToggleFavorite(course.id) }
            )
            Spacer(modifier = Modifier.height(8.dp))
        }
    }
}

/**
 * Continue Learning Card
 */
@Composable
fun ContinueLearningCard(
    course: Course,
    onCourseClick: () -> Unit,
    isFavorite: Boolean,
    onToggleFavorite: () -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(12.dp))
            .clickable { onCourseClick() },
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(12.dp),
            horizontalArrangement = Arrangement.spacedBy(12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Course Image
            Box(
                modifier = Modifier
                    .size(80.dp)
                    .background(MaterialTheme.colorScheme.surfaceVariant)
                    .clip(RoundedCornerShape(8.dp))
            ) {
                AsyncImage(
                    model = course.imageUrl,
                    contentDescription = course.title,
                    modifier = Modifier.fillMaxSize(),
                    contentScale = ContentScale.Crop
                )
            }

            // Course Info
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = course.title,
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Bold,
                    maxLines = 1
                )

                Text(
                    text = course.instructor,
                    fontSize = 11.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )

                Spacer(modifier = Modifier.height(4.dp))

                LinearProgressIndicator(
                    progress = { course.progress / 100f },
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(4.dp)
                        .clip(RoundedCornerShape(2.dp)),
                    color = MaterialTheme.colorScheme.primary,
                    trackColor = MaterialTheme.colorScheme.surfaceVariant
                )

                Text(
                    text = "${course.progress}% Complete",
                    fontSize = 9.sp,
                    color = MaterialTheme.colorScheme.primary,
                    fontWeight = FontWeight.Bold
                )
            }

            // Favorite Button
            IconButton(
                onClick = onToggleFavorite,
                modifier = Modifier.size(32.dp)
            ) {
                Icon(
                    imageVector = if (isFavorite) Icons.Filled.Favorite
                    else Icons.Outlined.FavoriteBorder,
                    contentDescription = "Favorite",
                    tint = if (isFavorite) Color.Red else Color.Gray,
                    modifier = Modifier.size(20.dp)
                )
            }
        }
    }
}

/**
 * Popular Courses Section
 */
@Composable
fun PopularCoursesSection(
    courses: List<Course>,
    onCourseClick: (Course) -> Unit,
    favorites: Set<Int>,
    onToggleFavorite: (Int) -> Unit
) {
    LazyColumn(
        modifier = Modifier.padding(horizontal = 16.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        items(courses) { course ->
            PopularCourseCard(
                course = course,
                onCourseClick = { onCourseClick(course) },
                isFavorite = course.id in favorites,
                onToggleFavorite = { onToggleFavorite(course.id) }
            )
        }
    }
}

/**
 * Popular Course Card
 */
@Composable
fun PopularCourseCard(
    course: Course,
    onCourseClick: () -> Unit,
    isFavorite: Boolean,
    onToggleFavorite: () -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(12.dp))
            .clickable { onCourseClick() },
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(12.dp),
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            // Course Image
            Box(
                modifier = Modifier
                    .size(80.dp)
                    .background(MaterialTheme.colorScheme.surfaceVariant)
                    .clip(RoundedCornerShape(8.dp))
            ) {
                AsyncImage(
                    model = course.imageUrl,
                    contentDescription = course.title,
                    modifier = Modifier.fillMaxSize(),
                    contentScale = ContentScale.Crop
                )
            }

            // Course Info
            Column(
                modifier = Modifier
                    .weight(1f)
                    .padding(vertical = 4.dp)
            ) {
                Text(
                    text = course.title,
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Bold,
                    maxLines = 1
                )

                Row(
                    horizontalArrangement = Arrangement.spacedBy(6.dp),
                    modifier = Modifier.padding(vertical = 4.dp)
                ) {
                    Icon(
                        imageVector = Icons.Filled.Star,
                        contentDescription = "Rating",
                        tint = Color.Yellow,
                        modifier = Modifier.size(12.dp)
                    )
                    Text(
                        text = "${course.rating}",
                        fontSize = 10.sp,
                        fontWeight = FontWeight.Bold
                    )
                    Text(
                        text = "(${course.students / 1000}k)",
                        fontSize = 10.sp,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }

                Row(
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Badge(
                        containerColor = MaterialTheme.colorScheme.primaryContainer,
                        contentColor = MaterialTheme.colorScheme.onPrimaryContainer
                    ) {
                        Text(
                            text = course.category,
                            fontSize = 9.sp,
                            modifier = Modifier.padding(horizontal = 6.dp, vertical = 2.dp)
                        )
                    }
                    Badge(
                        containerColor = MaterialTheme.colorScheme.secondaryContainer,
                        contentColor = MaterialTheme.colorScheme.onSecondaryContainer
                    ) {
                        Text(
                            text = course.difficulty,
                            fontSize = 9.sp,
                            modifier = Modifier.padding(horizontal = 6.dp, vertical = 2.dp)
                        )
                    }
                }
            }

            // Favorite Button
            IconButton(
                onClick = onToggleFavorite,
                modifier = Modifier.size(32.dp)
            ) {
                Icon(
                    imageVector = if (isFavorite) Icons.Filled.Favorite
                    else Icons.Outlined.FavoriteBorder,
                    contentDescription = "Favorite",
                    tint = if (isFavorite) Color.Red else Color.Gray,
                    modifier = Modifier.size(18.dp)
                )
            }
        }
    }
}

// ==================== Course Detail Screen ====================

@Composable
fun CourseDetailScreen(
    course: Course,
    onBack: () -> Unit,
    onEnroll: () -> Unit
) {
    var showSnackbar by remember { mutableStateOf(false) }
    val context = LocalContext.current

    if (showSnackbar) {
        LaunchedEffect(Unit) {
            showSnackbar = false
        }
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
    ) {
        // Back Button with Image
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(200.dp)
                .background(MaterialTheme.colorScheme.surfaceVariant)
        ) {
            AsyncImage(
                model = course.imageUrl,
                contentDescription = course.title,
                modifier = Modifier.fillMaxSize(),
                contentScale = ContentScale.Crop
            )

            IconButton(
                onClick = onBack,
                modifier = Modifier
                    .align(Alignment.TopStart)
                    .padding(8.dp)
                    .background(
                        color = Color.White.copy(alpha = 0.9f),
                        shape = RoundedCornerShape(50)
                    )
            ) {
                Icon(
                    imageVector = Icons.Default.ArrowBack,
                    contentDescription = "Back"
                )
            }
        }

        Column(modifier = Modifier.padding(16.dp)) {
            // Title and Instructor
            Text(
                text = course.title,
                fontSize = 24.sp,
                fontWeight = FontWeight.Bold
            )

            Text(
                text = course.instructor,
                fontSize = 14.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                modifier = Modifier.padding(top = 4.dp)
            )

            Spacer(modifier = Modifier.height(16.dp))

            // Rating, Students, Duration
            Row(
                horizontalArrangement = Arrangement.spacedBy(12.dp),
                modifier = Modifier.fillMaxWidth()
            ) {
                DetailInfoCard(
                    icon = Icons.Filled.Star,
                    label = "Rating",
                    value = course.rating.toString()
                )
                DetailInfoCard(
                    icon = Icons.Filled.Person,
                    label = "Students",
                    value = "${course.students / 1000}k"
                )
                DetailInfoCard(
                    icon = Icons.Filled.AccessTime,
                    label = "Duration",
                    value = course.duration
                )
            }

            Spacer(modifier = Modifier.height(16.dp))

            // Description
            Text(
                text = "Description",
                fontSize = 16.sp,
                fontWeight = FontWeight.Bold
            )
            Text(
                text = course.description,
                fontSize = 13.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                modifier = Modifier.padding(top = 8.dp)
            )

            Spacer(modifier = Modifier.height(16.dp))

            // Course Info Grid
            Row(
                horizontalArrangement = Arrangement.spacedBy(12.dp),
                modifier = Modifier.fillMaxWidth()
            ) {
                CourseInfoColumn(
                    title = "Total Lessons",
                    value = course.lessons.toString(),
                    modifier = Modifier.weight(1f)
                )
                CourseInfoColumn(
                    title = "Difficulty",
                    value = course.difficulty,
                    modifier = Modifier.weight(1f)
                )
                CourseInfoColumn(
                    title = "Category",
                    value = course.category,
                    modifier = Modifier.weight(1f)
                )
            }

            Spacer(modifier = Modifier.height(16.dp))

            // Lessons List
            Text(
                text = "Course Content (${course.lessons_list.size} lessons)",
                fontSize = 16.sp,
                fontWeight = FontWeight.Bold
            )

            Spacer(modifier = Modifier.height(8.dp))

            Column(
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                course.lessons_list.forEachIndexed { index, lesson ->
                    LessonItem(lesson = lesson, lessonNumber = index + 1)
                }
            }

            Spacer(modifier = Modifier.height(20.dp))

            // Enroll Button
            Button(
                onClick = {
                    showSnackbar = true
                    onEnroll()
                },
                modifier = Modifier
                    .fillMaxWidth()
                    .height(48.dp),
                shape = RoundedCornerShape(12.dp)
            ) {
                Text("Enroll Now", fontSize = 16.sp, fontWeight = FontWeight.Bold)
            }

            Spacer(modifier = Modifier.height(20.dp))
        }
    }
}

/**
 * Detail Info Card for Course Details
 */
@Composable
fun DetailInfoCard(
    icon: androidx.compose.material.icons.Icons,
    label: String,
    value: String
) {
    Card(
        modifier = Modifier
            .size(100.dp)
            .clip(RoundedCornerShape(12.dp)),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(12.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Icon(
                imageVector = icon,
                contentDescription = label,
                modifier = Modifier.size(24.dp),
                tint = MaterialTheme.colorScheme.primary
            )
            Text(
                text = value,
                fontSize = 12.sp,
                fontWeight = FontWeight.Bold,
                modifier = Modifier.padding(top = 4.dp)
            )
            Text(
                text = label,
                fontSize = 9.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}

/**
 * Course Info Column
 */
@Composable
fun CourseInfoColumn(
    title: String,
    value: String,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier
            .background(
                color = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f),
                shape = RoundedCornerShape(8.dp)
            )
            .padding(12.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            text = value,
            fontSize = 14.sp,
            fontWeight = FontWeight.Bold
        )
        Text(
            text = title,
            fontSize = 10.sp,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

/**
 * Lesson Item for displaying individual lessons
 */
@Composable
fun LessonItem(lesson: Lesson, lessonNumber: Int) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(8.dp)),
        elevation = CardDefaults.cardElevation(defaultElevation = 1.dp)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(12.dp),
            horizontalArrangement = Arrangement.spacedBy(12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Lesson Number
            Box(
                modifier = Modifier
                    .size(36.dp)
                    .background(
                        color = MaterialTheme.colorScheme.primaryContainer,
                        shape = RoundedCornerShape(8.dp)
                    ),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = lessonNumber.toString(),
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Bold,
                    color = MaterialTheme.colorScheme.onPrimaryContainer
                )
            }

            // Lesson Info
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = lesson.title,
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Bold
                )
                Text(
                    text = lesson.duration,
                    fontSize = 11.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }

            // Play Button or Checkmark
            if (lesson.isCompleted) {
                Icon(
                    imageVector = Icons.Default.CheckCircle,
                    contentDescription = "Completed",
                    tint = Color.Green,
                    modifier = Modifier.size(24.dp)
                )
            } else {
                Icon(
                    imageVector = Icons.Default.PlayCircleFilled,
                    contentDescription = "Play",
                    tint = MaterialTheme.colorScheme.primary,
                    modifier = Modifier.size(24.dp)
                )
            }
        }
    }
}

// ==================== Favorites Screen ====================

@Composable
fun FavoritesScreen(
    favorites: Set<Int>,
    onCourseClick: (Course) -> Unit,
    onBack: () -> Unit
) {
    val allCourses = getSampleCourses()
    val favoriteCourses = allCourses.filter { it.id in favorites }

    Column(modifier = Modifier.fillMaxSize()) {
        // Header
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            IconButton(onClick = onBack) {
                Icon(
                    imageVector = Icons.Default.ArrowBack,
                    contentDescription = "Back"
                )
            }
            Text(
                text = "Favorite Courses",
                fontSize = 22.sp,
                fontWeight = FontWeight.Bold
            )
        }

        if (favoriteCourses.isEmpty()) {
            // Empty State
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(32.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.Center
            ) {
                Icon(
                    imageVector = Icons.Default.FavoriteBorder,
                    contentDescription = "No Favorites",
                    modifier = Modifier.size(64.dp),
                    tint = MaterialTheme.colorScheme.onSurfaceVariant
                )
                Text(
                    text = "No favorites yet",
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Bold,
                    modifier = Modifier.padding(top = 16.dp)
                )
                Text(
                    text = "Add courses to your favorites to access them quickly",
                    fontSize = 13.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    textAlign = androidx.compose.ui.text.style.TextAlign.Center,
                    modifier = Modifier.padding(top = 8.dp)
                )
            }
        } else {
            // List of Favorites
            LazyColumn(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(horizontal = 16.dp),
                verticalArrangement = Arrangement.spacedBy(8.dp),
                contentPadding = PaddingValues(bottom = 16.dp)
            ) {
                items(favoriteCourses) { course ->
                    Card(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clip(RoundedCornerShape(12.dp))
                            .clickable { onCourseClick(course) },
                        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
                    ) {
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(12.dp),
                            horizontalArrangement = Arrangement.spacedBy(12.dp)
                        ) {
                            Box(
                                modifier = Modifier
                                    .size(100.dp)
                                    .background(MaterialTheme.colorScheme.surfaceVariant)
                                    .clip(RoundedCornerShape(8.dp))
                            ) {
                                AsyncImage(
                                    model = course.imageUrl,
                                    contentDescription = course.title,
                                    modifier = Modifier.fillMaxSize(),
                                    contentScale = ContentScale.Crop
                                )
                            }

                            Column(modifier = Modifier.weight(1f)) {
                                Text(
                                    text = course.title,
                                    fontSize = 14.sp,
                                    fontWeight = FontWeight.Bold,
                                    maxLines = 2
                                )

                                Text(
                                    text = course.instructor,
                                    fontSize = 11.sp,
                                    color = MaterialTheme.colorScheme.onSurfaceVariant
                                )

                                Row(
                                    horizontalArrangement = Arrangement.spacedBy(6.dp),
                                    modifier = Modifier.padding(top = 4.dp)
                                ) {
                                    Icon(
                                        imageVector = Icons.Filled.Star,
                                        contentDescription = "Rating",
                                        tint = Color.Yellow,
                                        modifier = Modifier.size(12.dp)
                                    )
                                    Text(
                                        text = "${course.rating}",
                                        fontSize = 10.sp,
                                        fontWeight = FontWeight.Bold
                                    )
                                    Text(
                                        text = "(${course.students / 1000}k)",
                                        fontSize = 10.sp,
                                        color = MaterialTheme.colorScheme.onSurfaceVariant
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

// ==================== Profile Screen ====================

@Composable
fun ProfileScreen(
    userProfile: UserProfile,
    onBack: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
    ) {
        // Header with Back Button
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            IconButton(onClick = onBack) {
                Icon(
                    imageVector = Icons.Default.ArrowBack,
                    contentDescription = "Back"
                )
            }
            Text(
                text = "Profile",
                fontSize = 22.sp,
                fontWeight = FontWeight.Bold
            )
        }

        // Profile Card
        Card(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp)
                .clip(RoundedCornerShape(16.dp)),
            elevation = CardDefaults.cardElevation(defaultElevation = 4.dp)
        ) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(20.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                // Profile Picture
                Box(
                    modifier = Modifier
                        .size(100.dp)
                        .background(
                            color = MaterialTheme.colorScheme.primaryContainer,
                            shape = RoundedCornerShape(50)
                        ),
                    contentAlignment = Alignment.Center
                ) {
                    AsyncImage(
                        model = userProfile.profileImage,
                        contentDescription = "Profile",
                        modifier = Modifier
                            .fillMaxSize()
                            .clip(RoundedCornerShape(50)),
                        contentScale = ContentScale.Crop
                    )
                }

                // Name
                Text(
                    text = userProfile.name,
                    fontSize = 20.sp,
                    fontWeight = FontWeight.Bold,
                    modifier = Modifier.padding(top = 16.dp)
                )

                // Email
                Text(
                    text = userProfile.email,
                    fontSize = 13.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }

        Spacer(modifier = Modifier.height(20.dp))

        // Statistics Grid
        Column(modifier = Modifier.padding(horizontal = 16.dp)) {
            Text(
                text = "Learning Statistics",
                fontSize = 16.sp,
                fontWeight = FontWeight.Bold,
                modifier = Modifier.padding(bottom = 12.dp)
            )

            Row(
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                modifier = Modifier.fillMaxWidth()
            ) {
                StatisticCard(
                    title = "Completed",
                    value = userProfile.completedCourses.toString(),
                    icon = Icons.Filled.CheckCircle,
                    modifier = Modifier.weight(1f)
                )
                StatisticCard(
                    title = "Certificates",
                    value = userProfile.certificatesEarned.toString(),
                    icon = Icons.Filled.EmojiEvents,
                    modifier = Modifier.weight(1f)
                )
            }

            Spacer(modifier = Modifier.height(8.dp))

            Row(
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                modifier = Modifier.fillMaxWidth()
            ) {
                StatisticCard(
                    title = "Study Hours",
                    value = userProfile.studyHours.toString(),
                    icon = Icons.Filled.AccessTime,
                    modifier = Modifier.weight(1f)
                )
                StatisticCard(
                    title = "Streak",
                    value = userProfile.learningStreak.toString(),
                    icon = Icons.Filled.LocalFireDepartment,
                    modifier = Modifier.weight(1f)
                )
            }
        }

        Spacer(modifier = Modifier.height(20.dp))

        // Achievement Section
        Column(modifier = Modifier.padding(horizontal = 16.dp)) {
            Text(
                text = "Achievements",
                fontSize = 16.sp,
                fontWeight = FontWeight.Bold,
                modifier = Modifier.padding(bottom = 12.dp)
            )

            AchievementBadge("Quick Starter", "Completed your first course")
            Spacer(modifier = Modifier.height(8.dp))
            AchievementBadge("On Fire!", "Maintained ${userProfile.learningStreak} day streak")
            Spacer(modifier = Modifier.height(8.dp))
            AchievementBadge("Certified", "Earned ${userProfile.certificatesEarned} certificates")
        }

        Spacer(modifier = Modifier.height(20.dp))

        // Settings Button
        Button(
            onClick = { },
            modifier = Modifier
                .fillMaxWidth()
                .height(48.dp)
                .padding(horizontal = 16.dp),
            shape = RoundedCornerShape(12.dp),
            colors = ButtonDefaults.buttonColors(
                containerColor = MaterialTheme.colorScheme.secondaryContainer,
                contentColor = MaterialTheme.colorScheme.onSecondaryContainer
            )
        ) {
            Icon(
                imageVector = Icons.Default.Settings,
                contentDescription = "Settings",
                modifier = Modifier.size(20.dp)
            )
            Spacer(modifier = Modifier.width(8.dp))
            Text("Settings", fontSize = 14.sp, fontWeight = FontWeight.Bold)
        }

        Spacer(modifier = Modifier.height(20.dp))
    }
}

/**
 * Statistic Card for Profile
 */
@Composable
fun StatisticCard(
    title: String,
    value: String,
    icon: androidx.compose.material.icons.Icons,
    modifier: Modifier = Modifier
) {
    Card(
        modifier = modifier
            .clip(RoundedCornerShape(12.dp)),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Icon(
                imageVector = icon,
                contentDescription = title,
                modifier = Modifier.size(28.dp),
                tint = MaterialTheme.colorScheme.primary
            )
            Text(
                text = value,
                fontSize = 18.sp,
                fontWeight = FontWeight.Bold,
                modifier = Modifier.padding(top = 8.dp)
            )
            Text(
                text = title,
                fontSize = 11.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}

/**
 * Achievement Badge Component
 */
@Composable
fun AchievementBadge(title: String, description: String) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(12.dp)),
        elevation = CardDefaults.cardElevation(defaultElevation = 1.dp)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(12.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Icon(
                imageVector = Icons.Default.EmojiEvents,
                contentDescription = "Achievement",
                modifier = Modifier.size(32.dp),
                tint = Color.Yellow
            )

            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = title,
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Bold
                )
                Text(
                    text = description,
                    fontSize = 11.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }

            Icon(
                imageVector = Icons.Default.CheckCircle,
                contentDescription = "Unlocked",
                modifier = Modifier.size(24.dp),
                tint = Color.Green
            )
        }
    }
}

// ==================== Theme Colors ====================

/**
 * Light color scheme for Material Design 3
 */
@Composable
fun lightColorScheme() = lightColorScheme(
    primary = Color(0xFF6750A4),
    onPrimary = Color.White,
    primaryContainer = Color(0xFFEADDFF),
    onPrimaryContainer = Color(0xFF21005E),
    secondary = Color(0xFF625B71),
    onSecondary = Color.White,
    secondaryContainer = Color(0xFFE8DEF8),
    onSecondaryContainer = Color(0xFF1D192B),
    tertiary = Color(0xFF7D5260),
    onTertiary = Color.White,
    tertiaryContainer = Color(0xFFFFD8E4),
    onTertiaryContainer = Color(0xFF31111D),
    error = Color(0xFFB3261E),
    onError = Color.White,
    errorContainer = Color(0xFFF9DEDC),
    onErrorContainer = Color(0xFF410E0B),
    background = Color(0xFFFFFBFE),
    onBackground = Color(0xFF1C1B1F),
    surface = Color(0xFFFFFBFE),
    onSurface = Color(0xFF1C1B1F),
    surfaceVariant = Color(0xFFE7E0EC),
    onSurfaceVariant = Color(0xFF49454E)
)

/**
 * Dark color scheme for Material Design 3
 */
@Composable
fun darkColorScheme() = darkColorScheme(
    primary = Color(0xFFD0BCFF),
    onPrimary = Color(0xFF371E55),
    primaryContainer = Color(0xFF4F378B),
    onPrimaryContainer = Color(0xFFEADDFF),
    secondary = Color(0xFFCCC7F0),
    onSecondary = Color(0xFF332D41),
    secondaryContainer = Color(0xFF4A4458),
    onSecondaryContainer = Color(0xFFE8DEF8),
    tertiary = Color(0xFFEFB8C8),
    onTertiary = Color(0xFF492532),
    tertiaryContainer = Color(0xFF633B48),
    onTertiaryContainer = Color(0xFFFFD8E4),
    error = Color(0xFFF2B8B5),
    onError = Color(0xFF601410),
    errorContainer = Color(0xFF8C1D18),
    onErrorContainer = Color(0xFFF9DEDC),
    background = Color(0xFF1C1B1F),
    onBackground = Color(0xFFE6E1E6),
    surface = Color(0xFF1C1B1F),
    onSurface = Color(0xFFE6E1E6),
    surfaceVariant = Color(0xFF49454E),
    onSurfaceVariant = Color(0xFFCAC7D0)
)
