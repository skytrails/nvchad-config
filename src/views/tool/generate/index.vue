<template>
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
        <template slot="toolbar">
          <el-button
            size="small"
            type="primary"
            icon="el-icon-plus"
            class="ele-btn-icon"
            @click="importTable"
            v-if="permission.includes('sys:generate:batchGenerate')">导入业务表
          </el-button>
        </template>
        <template slot="toolbar">
          <el-button
            size="small"
            type="primary"
            icon="el-icon-edit"
            class="ele-btn-icon"
            @click="batchGenerate"
            :disabled="selection.length===0"
            v-if="permission.includes('sys:generate:batchGenerate')">批量生成
          </el-button>
        </template>
        <!-- 操作列 -->
        <template slot="action" slot-scope="{row}">
          <!--<el-link
            type="primary"
            :underline="false"
            icon="el-icon-edit"
            @click="openEdit(row)"
            v-if="permission.includes('sys:generate:edit')">修改
          </el-link>-->
          <el-popconfirm
            class="ele-action"
            title="确定要一键生成当前模块吗？生成后将覆盖已有文件"
            @confirm="generate(row)">
            <el-link
              type="primaryDashboard"
              slot="reference"
              :underline="false"
              icon="el-icon-_table"
              v-if="permission.includes('sys:generate:generate')">一键生成模块
            </el-link>
          </el-popconfirm>
          <el-popconfirm
            class="ele-action"
            title="确定要删除此业务表吗？"
            @confirm="remove(row)">
            <el-link
              type="danger"
              slot="reference"
              :underline="false"
              icon="el-icon-delete"
              v-if="permission.includes('sys:generate:delete')">删除
            </el-link>
          </el-popconfirm>
        </template>
      </ele-pro-table>
    </el-card>

    <!-- 导入业务表 -->
    <import-table ref="import" @search="$refs.table.reload();" />
  </div>
</template>

<script>
import { mapGetters } from "vuex";
import importTable from "./import-table";

export default {
  name: 'GenerateGenTab',
  components: {importTable},
  computed: {
    ...mapGetters(["permission"]),
  },
  data() {
    return {
      // 表格数据接口
      url: '/generate/index',
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
          columnKey: 'index',
          type: 'index',
          width: 45,
          align: 'center',
          showOverflowTooltip: true,
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
          prop: 'className',
          label: '类名',
          showOverflowTooltip: true,
          minWidth: 100,
          align: 'center',
        },
        {
          prop: 'tplCategory',
          label: '使用模板',
          showOverflowTooltip: true,
          minWidth: 100,
          align: 'center',
        },
        {
          prop: 'packageName',
          label: '包路径',
          showOverflowTooltip: true,
          minWidth: 200,
          align: 'center',
        },
        {
          prop: 'moduleName',
          label: '所属模块',
          showOverflowTooltip: true,
          minWidth: 100,
          align: 'center',
        },
        {
          prop: 'businessName',
          label: '业务名称',
          showOverflowTooltip: true,
          minWidth: 100,
          align: 'center',
        },
        {
          prop: 'functionName',
          label: '业务标题',
          showOverflowTooltip: true,
          minWidth: 100,
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
        {
          columnKey: 'action',
          label: '操作',
          width: 200,
          align: 'center',
          resizable: false,
          slot: 'action',
          fixed: "right"
        }
      ],
      // 表格搜索条件
      where: {},
      // 表格选中数据
      selection: [],
      // 当前编辑数据
      current: null,
      // 是否显示编辑弹窗
      showEdit: false,
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
     * 导入业务表
     */
    importTable(){
      this.$refs.import.show();
    },
    /* 显示编辑 */
    openEdit(row) {
      this.tableId = row.id || this.selection[0];
      this.showEdit = true
    },
    /* 删除 */
    remove(row) {
      const loading = this.$loading({lock: true});
      this.$http.delete('/generate/delete/' + [row.id]).then(res => {
        loading.close();
        if (res.data.code === 0) {
          this.$message.success(res.data.msg);
          this.reload();
        } else {
          this.$message.error(res.data.msg);
        }
      }).catch(e => {
        loading.close();
        this.$message.error(e.message);
      });
    },
    /* 一键生成 */
    generate(row) {
      const loading = this.$loading({lock: true});
      const tableNames = row.tableName || this.tableNames.join(',');
      if (tableNames == "") {
        this.msgError("请选择要生成的数据");
        return;
      }
      this.$confirm('确定要批量生成当前选择的模块吗?生成将覆盖已有的文件', '提示', {
        type: 'warning'
      }).then(() => {
        this.$http.post('/generate/batchGenCode', {tableNames: tableNames}).then(res => {
          loading.close();
          if (res.data.code === 0) {
            this.$message.success(res.data.msg);
          } else {
            this.$message.error(res.data.msg);
          }
        }).catch(e => {
          loading.close();
          this.$message.error(e.message);
        });
      }).catch(() => {
      });
    },
    /* 批量生成 */
    batchGenerate() {
      if (!this.selection.length) {
        this.$message.error('请至少选择一条数据');
        return;
      }
      this.$confirm('确定要批量生成当前选择的模块吗?生成将覆盖已有的文件', '提示', {
        type: 'warning'
      }).then(() => {
        const loading = this.$loading({lock: true});
        this.$http.post('/generate/batchGenerate', {tableNames: this.selection.map(d => d.tableName).join(',')}).then(res => {
          loading.close();
          if (res.data.code === 0) {
            this.$message.success(res.data.msg);
            this.reload();
          } else {
            this.$message.error(res.data.msg);
          }
        }).catch(e => {
          loading.close();
          this.$message.error(e.message);
        });
      }).catch(() => {
      });
    },
  }
}
</script>

<style scoped>
</style>
