# wk8-plp-database
# Justification for the Bee Farming Records Database Project

The Bee Farming Records Database project is designed to support the management and operation of bee farming activities through an organized system of records. The database provides a comprehensive framework for tracking essential aspects of bee farming, including beekeepers, apiaries, hives, queen bees, inspections, harvests, treatments, and feedings. This system is vital for ensuring the efficiency, traceability, and accountability of the operations involved in maintaining healthy bee colonies, which are critical for honey production and pollination services.

## Key Reasons for the Project:

1. **Enhanced Record Keeping**: Bee farming is a complex process that requires maintaining detailed records on various aspects of hive management. By centralizing this data in a single database, beekeepers can easily track the performance of their hives, apiaries, and queens over time.
  
2. **Improved Hive Management**: Each hive is connected to specific apiaries, and having a dedicated table for hives allows beekeepers to track their health, location, and status. This will help in managing beehives more effectively, ensuring proper care is provided and maximizing productivity.

3. **Data-Driven Decisions**: With proper records of inspections, treatments, and feedings, beekeepers can make informed decisions regarding colony health, pest management, and resource allocation. For example, if a particular hive is showing signs of stress or disease, the database can quickly provide historical context to assist in diagnosing the issue.

4. **Harvest Tracking**: The ability to track honey and other bee products such as beeswax, pollen, and propolis ensures that harvests are managed properly, allowing beekeepers to predict yields and plan their business operations effectively. It also helps in monitoring the seasonal trends of harvests, aiding in optimizing production.

5. **Legal and Regulatory Compliance**: Having a well-documented system can assist in meeting regulatory requirements for bee farming. Inspections and treatments, for example, need to be logged accurately to ensure that the hive is compliant with health and safety standards.

6. **Resource Management**: By recording feeding schedules and the type of feed provided, beekeepers can ensure that colonies receive the necessary nutritional support to thrive, particularly in periods when natural forage is scarce.

7. **Traceability and Accountability**: This database helps trace each decision made regarding a specific hive, from introducing queens to applying treatments, thus improving accountability and transparency.

## Relationship Between Tables in the Database

The relationships between tables in this schema ensure data integrity and logical connections across the system:

1. **Beekeepers to Apiaries**: 
   - A **beekeeper** manages one or more **apiaries**, with the `beekeeper_id` acting as a foreign key in the `Apiaries` table. This establishes a one-to-many relationship, where one beekeeper can have multiple apiaries, but each apiary is managed by a single beekeeper.

2. **Apiaries to Hives**: 
   - An **apiary** can have multiple **hives**. The `apiary_id` in the `Hives` table links each hive to its respective apiary, creating a one-to-many relationship between apiaries and hives.

3. **Hives to Queens**:
   - A **hive** can have one or more **queens** over time, though only one queen is active in the hive at any given moment. The `hive_id` in the `Queens` table links each queen to a specific hive, establishing a one-to-many relationship.

4. **Hives to Inspections**:
   - **Hives** are regularly inspected for health and colony status. Each **inspection** record is linked to a specific hive using the `hive_id` as a foreign key. This relationship is one-to-many, where one hive can have multiple inspections over time.

5. **Hives to Harvests**:
   - **Harvests** are linked to **hives** through the `hive_id`. This one-to-many relationship allows tracking of multiple harvests from a single hive.

6. **Hives to Treatments**:
   - A **hive** may require multiple **treatments** over its lifetime, such as for pests or diseases. The `hive_id` in the `Treatments` table links the treatments to the specific hive, ensuring a clear record of when and what treatments were applied.

7. **Hives to Feedings**:
   - **Feedings** are applied to **hives** to support colony health, especially in periods of stress. The `hive_id` in the `Feedings` table ties each feeding record to a specific hive.

8. **Beekeepers to Inspections, Harvests, Treatments, and Feedings**:
   - Beekeepers can be involved in various activities, such as inspections, harvests, treatments, and feedings. The `beekeeper_id` is used as a foreign key in the `Inspections`, `Harvests`, `Treatments`, and `Feedings` tables to track which beekeeper was responsible for each action. In some cases, these links can be null if the action was performed by another party.

## ERD Diagram
![ERD Diagram](<ERD diagram.png>)
