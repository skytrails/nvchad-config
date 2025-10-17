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
            <el-form-item label="筹款标题:">
              <el-input
                clearable
                v-model="where.title"
                placeholder="请输入筹款标题"/>
            </el-form-item>
          </el-col>
          <el-col :lg="6" :md="12">
            <el-form-item label="患者姓名:">
              <el-input
                clearable
                v-model="where.patientName"
                placeholder="请输入患者姓名"/>
            </el-form-item>
          </el-col>
          <el-col :lg="6" :md="12">
            <el-form-item label="状态:">
              <el-select
                clearable
                v-model="where.status"
                placeholder="全部"
                class="ele-fluid">
                <el-option label="未审核" value="1"/>
                <el-option label="已通过" value="2"/>
                <el-option label="已拒绝" value="3"/>
              </el-select>
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
<!--          <el-button-->
<!--            size="small"-->
<!--            type="primary"-->
<!--            icon="el-icon-plus"-->
<!--            class="ele-btn-icon"-->
<!--            @click="openEdit(null)">新增-->
<!--          </el-button>-->
        </template>
        <!-- 操作列 -->
        <template slot="action" slot-scope="{row}">
          <el-link
            icon="el-icon-view"
            :underline="false"
            @click="openEdit(row, 'detail')">查看详情
          </el-link>
          <el-popconfirm
            class="ele-action"
            title="确定要删除此认证记录吗？"
            @confirm="remove(row)">
            <el-link
              type="danger"
              slot="reference"
              :underline="false"
              icon="el-icon-delete">删除认证
            </el-link>
          </el-popconfirm>
        </template>
        <!-- 筹款人信息列 -->
        <template slot="projectRaiser" slot-scope="{row}">
          <div v-if="row.projectType === 1">
            <div>{{ row.patientName }}</div>
          </div>
          <div v-else>{{ row.organizationName }}</div>
        </template>
        <!-- 地区列 -->
        <template slot="city" slot-scope="{row}">
          {{ (row.province ? row.province : '') + (row.city ? row.city : '') + (row.district ? row.district : '') }}
        </template>
        <!-- 状态列 -->
        <template slot="status" slot-scope="{row}">
          <el-tag
            :type="row.status === 1 ? 'info' : (row.status === 2 ? '' : 'danger')"
            size="mini">{{ row.statusName }}
          </el-tag>
        </template>
      </ele-pro-table>
    </el-card>
    <!-- 编辑弹窗 -->
    <CertificationDetail
      v-if="showEdit"
      @close="showEdit=false"
      :data="current"
      :visible="showEdit"
      @done="reload"/>
  </div>
</template>

<script>
import { mapGetters } from "vuex";
import CertificationDetail from './certification-detail';
import * as $util from "ele-admin/packages/util";

export default {
  name: 'cfProjectsCertification',
  components: {CertificationDetail},
  computed: {
    ...mapGetters(["permission"]),
  },
  data() {
    return {
      // 表格数据接口
      url: '/cfProjectsCertification/index',
      // 表格列配置
      columns: [
        // {
        //   columnKey: 'selection',
        //   type: 'selection',
        //   width: 45,
        //   align: 'center',
        //   fixed: "left"
        // },
        {
          prop: 'id',
          label: 'ID',
          width: 60,
          align: 'center',
          showOverflowTooltip: true,
          fixed: "left"
        },
        {
          prop: 'createdAt',
          label: '申请时间',
          sortable: 'custom',
          showOverflowTooltip: true,
          minWidth: 160,
          align: 'center',
          formatter: (row, column, cellValue) => {
            return this.$util.toDateString(cellValue);
          }
        },
        {
          prop: 'projectTitle',
          label: '筹款标题',
          showOverflowTooltip: true,
          minWidth: 200,
          align: 'center',
        },
        {
          prop: 'projectRaiser',
          label: '患者/组织机构',
          showOverflowTooltip: true,
          minWidth: 165,
          align: 'center',
          slot: 'projectRaiser',
        },
        {
          prop: 'name',
          label: '认证人姓名',
          showOverflowTooltip: true,
          minWidth: 115,
          align: 'center',
        },
        {
          prop: 'idNo',
          label: '认证人证件号',
          showOverflowTooltip: true,
          minWidth: 160,
          align: 'center',
        },
        {
          prop: 'phone',
          label: '手机号',
          showOverflowTooltip: true,
          minWidth: 135,
          align: 'center',
        },
        {
          prop: 'city',
          label: '所在地区',
          showOverflowTooltip: true,
          minWidth: 200,
          align: 'center',
          slot: 'city'
        },
        {
          prop: 'status',
          label: '状态',
          align: 'center',
          width: 150,
          resizable: false,
          slot: 'status',
        },
        {
          prop: 'updatedAt',
          label: '审核时间',
          sortable: 'custom',
          showOverflowTooltip: true,
          minWidth: 160,
          align: 'center',
          formatter: (row, column, cellValue) => {
            return $util.toDateString(cellValue);
          }
        },
        {
          columnKey: 'action',
          label: '操作',
          width: 215,
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
      // 栏目列表
      cateList: [],
    };
  },
  mounted() {
  },
  methods: {
    /* 刷新表格 */
    reload() {
      this.showEdit = false;
      this.$refs.table.reload();
      // this.$refs.table.reload({where: this.where});
    },
    /* 重置搜索 */
    reset() {
      this.where = {};
      this.reload();
    },
    /* 显示编辑 */
    openEdit(row) {
      this.current = row == null ? {status: 1} : row;
      this.showEdit = true;
    },
    /* 删除 */
    remove(row) {
      const loading = this.$loading({lock: true});
      this.$http.post('/cfProjectsCertification/delete', [row.id]).then(res => {
        loading.close();
        if (res.data.code === 200) {
          this.$message.success(res.data.message);
          this.reload();
        } else {
          this.$message.error(res.data.message);
        }
      }).catch(e => {
        loading.close();
        this.$message.error(e.message);
      });
    },
    /* 批量删除 */
    removeBatch() {
      if (!this.selection.length) {
        this.$message.error('请至少选择一条数据');
        return;
      }
      this.$confirm('确定要删除选中的文章吗?', '提示', {
        type: 'warning'
      }).then(() => {
        const loading = this.$loading({lock: true});
        this.$http.post('/cfProjectsCertification/delete', this.selection.map(d => d.id)).then(res => {
          loading.close();
          if (res.data.code === 200) {
            this.$message.success(res.data.message);
            this.reload();
          } else {
            this.$message.error(res.data.message);
          }
        }).catch(e => {
          loading.close();
          this.$message.error(e.message);
        });
      }).catch(() => {
      });
    },
    /* 更改状态 */
    editStatus(row) {
      const loading = this.$loading({lock: true});
      let params = Object.assign({
        "id": row.id,
        "status": row.status
      })
      this.$http.post('/cfProjectsCertification/status', params).then(res => {
        loading.close();
        if (res.data.code === 200) {
          this.$message.success(res.data.message);
        } else {
          row.status = !row.status ? 1 : 2;
          this.$message.error(res.data.message);
        }
      }).catch(e => {
        loading.close();
        this.$message.error(e.message);
      });
    },
  }
}
</script>

<style scoped>
</style>
