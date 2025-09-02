const mongoose = require('mongoose');
const bcrypt = require('bcrypt');
const User = require('./models/User'); // adjust path if needed

mongoose.connect('mongodb://localhost:27017/blog-app', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

const seedUser = async () => {
  try {
    const hashedPassword = bcrypt.hashSync('12345', 10);

    const result = await User.updateOne(
      { email: 'carla@example.com' }, // match by email
      {
        $set: {
          firstName: 'Carla',
          lastName: 'Gidacan',
          age: '21',
          gender: 'Female',
          contactNumber: '09559409739',
          username: 'carla',
          password: hashedPassword,
          address: 'Address',
          isActive: true,
          type: 'admin',
        },
      },
      { upsert: true }
    );

    console.log('✅ User seeded:', result.upserted ? 'Inserted new user' : 'Updated existing user');
  } catch (err) {
    console.error('❌ Error seeding user:', err.message);
  } finally {
    mongoose.disconnect();
  }
};

seedUser();