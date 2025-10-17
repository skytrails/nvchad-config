<template>
  <el-dialog title="导入业务表" :visible.sync="visible" width="65%" top="5vh">
    <div class="ele-body">
      <el-card shadow="never">
        <!-- 搜索表单 -->
        <el-form
          :model="where"
          label-width="77px"
          class="ele-form-search"
          @keyup.enter.native="reload"
          @submit.native.prevent>
          <el-row :gutter="15">
            <el-col :lg="6" :md="12">
              <el-form-item label="表名称:">
                <el-input
                  clearable
                  v-model="where.tableName"
                  placeholder="请输入表名称"/>
              </el-form-item>
            </el-col>
            <el-col :lg="6" :md="12">
              <el-form-item label="表描述:">
                <el-input
                  clearable
                  v-model="where.tableComment"
                  placeholder="请输入表描述"/>
              </el-form-item>
            </el-col>
            <el-col :lg="6" :md="12">
              <div class="ele-form-actions">
                <el-button
                  type="primary"
                  icon="el-icon-search"
                  class="ele-btn-icon"
                  @click="reload">查询
                </el-button>
                <el-button @click="reset">重置</el-button>
              </div>
            </el-col>
          </el-row>
        </el-form>
        <!-- 数据表格 -->
        <ele-pro-table
          ref="table"
          :where="where"
          :datasource="url"
          :columns="columns"
          :selection.sync="selection"
          height="calc(100vh - 315px)">
          <!-- 表头工具栏 -->
          
        </ele-pro-table>
      </el-card>
    </div>
    <div slot="footer">
      <el-button type="primary" @click="importTable">确定</el-button>
      <el-button @click="visible = false">取消</el-button>
    </div>
  </el-dialog>
</template>

<script>
import { mapGetters } from "vuex";

export default {
  name: 'ImporTable',
  components: {},
  computed: {
    ...mapGetters(["permission"]),
  },
  data() {
    return {
      // 表格数据接口
      url: '/generate/genDbTableList',
      // 表格列配置
      columns: [
        {
          columnKey: 'selection',
          type: 'selection',
          width: 45,
          align: 'center',
          fixed: "left"
        },
        {
          prop: 'tableName',
          label: '表名称',
          showOverflowTooltip: true,
          minWidth: 150,
          align: 'center',
        },
        {
          prop: 'tableComment',
          label: '表备注',
          showOverflowTooltip: true,
          minWidth: 150,
          align: 'center',
        },
        {
          prop: 'createTime',
          label: '创建时间',
          sortable: 'custom',
          showOverflowTooltip: true,
          minWidth: 160,
          align: 'center',
          formatter: (row, column, cellValue) => {
            return this.$util.toDateString(cellValue);
          }
        },
      ],
      // 表格搜索条件
      where: {},
      // 表格选中数据
      selection: [],
      // 遮罩层
      visible: false,
    };
  },
  methods: {
    /* 刷新表格 */
    reload() {
      this.$refs.table.reload({where: this.where});
    },
    /* 重置搜索 */
    reset() {
      this.where = {};
      this.reload();
    },
    /**
     * 显示弹窗
     */
    show() {
      this.visible = true;
    },
    /**
     * 导入业务表
     */
    importTable(){
      if (this.selection.length === 0) return this.$message.error('请至少选择一条数据');
      let tableNames = this.selection.map(d => d.tableName);
      this.$confirm('确定要导入所选中的业务表吗?', '提示', {type: 'warning'}).then(() => {
        const loading = this.$loading({lock: true});
        this.$http.post('/generate/importTable', tableNames).then(res => {
          loading.close();
          if (res.data.code === 0) {
            this.$message.success(res.data.msg);
            this.visible = false;
            this.$emit("search");
          } else {
            this.$message.error(res.data.msg);
          }
        }).catch(e => {
          loading.close();
          this.$message.error(e.message);
        });
      }).catch(() => 0);
    },
  }
}
</script>

<style scoped>
</style>